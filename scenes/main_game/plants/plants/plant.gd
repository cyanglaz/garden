class_name Plant
extends Node2D

const AREA_SIZE_PER_CURSE_PARTICLE := 5
const CURSE_PARTICLE_Y_OFFSET := 4.0
const POPUP_SHOW_TIME := 0.3
const POPUP_DESTROY_TIME:= 1.2
const POPUP_OFFSET := Vector2.RIGHT * 8 + Vector2.UP * 12
const POPUP_LABEL_ICON_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label_icon.tscn")
const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")

enum AbilityType {
	END_TURN,
	START_TURN,
	BLOOM,
}

@warning_ignore("unused_signal")
signal bloom_started()
@warning_ignore("unused_signal")
signal bloom_completed()
signal action_application_completed()

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine
@onready var enemy_particle: GPUParticles2D = %EnemyParticle
@onready var bloom_particle: GPUParticles2D = %BloomParticle
@onready var plant_ability_container: PlantAbilityContainer = %PlantAbilityContainer
@onready var field_status_container: FieldStatusContainer = %FieldStatusContainer
@onready var _buff_sound: AudioStreamPlayer2D = %BuffSound
@onready var _point_audio: AudioStreamPlayer2D = %PointAudio

var light:ResourcePoint = ResourcePoint.new()
var water:ResourcePoint = ResourcePoint.new()
var field:Field: get = _get_field, set = _set_field
var _weak_field:WeakRef = weakref(null)

var data:PlantData:set = _set_data

func _ready() -> void:
	fsm.start()
	bloom_particle.one_shot = true
	bloom_particle.emitting = false
	field_status_container.request_hook_message_popup.connect(_on_request_hook_message_popup)
	_resize_enemy_particle()

func trigger_ability(ability_type:AbilityType) -> void:
	await plant_ability_container.trigger_ability(ability_type, self)

func handle_turn_end() -> void:
	field_status_container.handle_status_on_turn_end()

func handle_tool_application_hook() -> void:
	await field_status_container.handle_tool_application_hook(self)

func handle_tool_discard_hook(count:int) -> void:
	await field_status_container.handle_tool_discard_hook(self, count)

func handle_start_turn_hook(_combat_main:CombatMain) -> void:
	await trigger_ability(Plant.AbilityType.START_TURN)

func handle_end_turn_hook(combat_main:CombatMain) -> void:
	await field_status_container.handle_end_turn_hook(combat_main, self)
	await trigger_ability(Plant.AbilityType.END_TURN)

func apply_weather_actions(weather_data:WeatherData) -> void:
	await apply_actions(weather_data.actions)

func apply_actions(actions:Array) -> void:
	if is_bloom():
		await Util.await_for_tiny_time()
		action_application_completed.emit()
		return
	#await _play_action_from_gui_animation(action, from_gui)
	for action in actions:
		match action.type:
			ActionData.ActionType.LIGHT:
				await _apply_light_action(action)
			ActionData.ActionType.WATER:
				await _apply_water_action(action)
			ActionData.ActionType.PEST, ActionData.ActionType.FUNGUS, ActionData.ActionType.RECYCLE, ActionData.ActionType.GREENHOUSE, ActionData.ActionType.DEW:
				await _apply_field_status_action(action)
			_:
				pass
	action_application_completed.emit()

func is_bloom() -> bool:
	return (light.max_value <=0 || light.is_full) && (water.max_value <=0 || water.is_full)

func bloom() -> void:
	fsm.push("PlantStateBloom")

func show_bloom_popup() -> void:
	_point_audio.play()
	# TODO:

func get_pixel_height() -> float:
	var sprite_frames:SpriteFrames = plant_sprite.sprite_frames
	var frame_texture:Texture2D = sprite_frames.get_frame_texture("bloom", 0)
	var image := frame_texture.get_image()
	var used_rect := image.get_used_rect()
	return used_rect.size.y

#endregion

#region private functions
func _show_resource_icon_popup(icon_id:String, text:String, equal:bool) -> void:
	_buff_sound.play()
	var popup:PopupLabelIcon = POPUP_LABEL_ICON_SCENE.instantiate()
	if equal:
		popup.switch_icon_label = true
	var color:Color = Constants.COLOR_WHITE
	popup.setup(text, color, load(Util.get_image_path_for_resource_id(icon_id)))
	var popup_location:Vector2 = Util.get_node_canvas_position(self) + POPUP_OFFSET
	Events.request_display_popup_things.emit(popup, 6, 3, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, popup_location)
	await Util.create_scaled_timer(POPUP_SHOW_TIME).timeout

func _show_popup_action_indicator(action_data:ActionData) -> void:
	var true_value := _get_action_true_value(action_data)
	var text := str(true_value)
	var equal := false
	match action_data.operator_type:
		ActionData.OperatorType.INCREASE:
			text = "+" + text
		ActionData.OperatorType.DECREASE:
			text = "-" + text
		ActionData.OperatorType.EQUAL_TO:
			equal = true
			text = "=" + text
	var resource_id := Util.get_action_id_with_action_type(action_data.type)
	await _show_resource_icon_popup(resource_id, text, equal)

func _apply_light_action(action:ActionData) -> void:
	var true_value := _get_action_true_value(action)
	await _show_popup_action_indicator(action)
	match action.operator_type:
		ActionData.OperatorType.INCREASE:
			light.value += true_value
		ActionData.OperatorType.DECREASE:
			light.value -= true_value
		ActionData.OperatorType.EQUAL_TO:
			light.value = true_value

func _apply_water_action(action:ActionData) -> void:
	var true_value := _get_action_true_value(action)
	await _show_popup_action_indicator(action)
	var old_water_value := water.value
	match action.operator_type:
		ActionData.OperatorType.INCREASE:
			water.value += true_value
		ActionData.OperatorType.DECREASE:
			water.value -= true_value
		ActionData.OperatorType.EQUAL_TO:
			water.value = true_value
	var water_increasing := water.value - old_water_value > 0
	if water_increasing:
		await field_status_container.handle_add_water_hook(self)

func _apply_field_status_action(action:ActionData) -> void:
	var field_status_id := Util.get_action_id_with_action_type(action.type)
	var true_value := _get_action_true_value(action)
	var stack := 0
	match action.operator_type:
		ActionData.OperatorType.INCREASE:
			stack = true_value
		ActionData.OperatorType.DECREASE:
			stack = -true_value
		ActionData.OperatorType.EQUAL_TO:
			stack = true_value
	await _show_popup_action_indicator(action)
	field_status_container.update_status(field_status_id, stack, self)

func _get_action_true_value(action_data:ActionData) -> int:
	return action_data.get_calculated_value(self)

func _resize_enemy_particle() -> void:
	var sprite_frames:SpriteFrames = plant_sprite.sprite_frames
	var current_animation:StringName = plant_sprite.animation
	var frame_texture:Texture2D = sprite_frames.get_frame_texture(current_animation, 0)
	var image := frame_texture.get_image()
	var used_rect := image.get_used_rect()
	enemy_particle.process_material.emission_box_extents = Vector3(used_rect.size.x/2.0, used_rect.size.y/2.0, 1)
	var area_size :float = enemy_particle.process_material.emission_box_extents.x * enemy_particle.process_material.emission_box_extents.y
	var number_of_particles := area_size / AREA_SIZE_PER_CURSE_PARTICLE
	enemy_particle.amount = int(number_of_particles)
	enemy_particle.position.y = - used_rect.size.y/2.0 + CURSE_PARTICLE_Y_OFFSET

func _reposition_bloom_particle() -> void:
	var sprite_frames:SpriteFrames = plant_sprite.sprite_frames
	var current_animation:StringName = plant_sprite.animation
	var frame_texture:Texture2D = sprite_frames.get_frame_texture(current_animation, 0)
	var image := frame_texture.get_image()
	var used_rect := image.get_used_rect()
	bloom_particle.position.y = - used_rect.size.y/2.0
	
#region events
func _on_request_hook_message_popup(status_data:FieldStatusData) -> void:
	var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	var color:Color = Constants.COLOR_RED2
	match status_data.type:
		FieldStatusData.Type.BAD:
			color = Constants.COLOR_RED2
		FieldStatusData.Type.GOOD:
			color = Constants.COLOR_YELLOW2
	popup.setup(status_data.popup_message, color)
	var popup_location:Vector2 = Util.get_node_canvas_position(self) + POPUP_OFFSET
	Events.request_display_popup_things.emit(popup, 10, 1, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, popup_location)
	await Util.create_scaled_timer(POPUP_SHOW_TIME).timeout

#endregion

#region setter/getter

func _set_data(value:PlantData) -> void:
	data = value
	light.setup(0, data.light)
	water.setup(0, data.water)
	plant_ability_container.setup_with_plant_data(data)
	field_status_container.setup_with_plant(self)

func _get_field() -> Field:
	return _weak_field.get_ref()

func _set_field(val:Field) -> void:
	_weak_field = weakref(val)

#endregion
