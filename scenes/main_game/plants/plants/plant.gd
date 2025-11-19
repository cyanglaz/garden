class_name Plant
extends Node2D

const POPUP_SHOW_TIME := 0.3
const POPUP_DESTROY_TIME:= 1.2
const POPUP_OFFSET := Vector2.RIGHT * 8 + Vector2.UP * 12
const POPUP_LABEL_ICON_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label_icon.tscn")
const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")

enum AbilityType {
	END_TURN,
	START_TURN,
}

@warning_ignore("unused_signal")
signal bloom_started()
@warning_ignore("unused_signal")
signal bloom_completed()
signal action_application_completed()

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine
@onready var plant_ability_container: PlantAbilityContainer = %PlantAbilityContainer
@onready var _buff_sound: AudioStreamPlayer2D = %BuffSound
@onready var _point_audio: AudioStreamPlayer2D = %PointAudio

var light:ResourcePoint = ResourcePoint.new()
var water:ResourcePoint = ResourcePoint.new()
var status_manager:FieldStatusManager = FieldStatusManager.new()
var field:Field: get = _get_field, set = _set_field
var _weak_field:WeakRef = weakref(null)

var data:PlantData:set = _set_data

func _ready() -> void:
	fsm.start()
	status_manager.request_hook_message_popup.connect(_on_request_hook_message_popup)

func trigger_ability(ability_type:AbilityType) -> void:
	await plant_ability_container.trigger_ability(ability_type, self)

func handle_turn_end() -> void:
	status_manager.handle_status_on_turn_end()

func handle_tool_application_hook() -> void:
	await status_manager.handle_tool_application_hook(self)

func handle_tool_discard_hook(count:int) -> void:
	await status_manager.handle_tool_discard_hook(self, count)

func handle_start_turn_hook(_combat_main:CombatMain) -> void:
	if is_bloom():
		await trigger_ability(Plant.AbilityType.START_TURN)

func handle_end_turn_hook(combat_main:CombatMain) -> void:
	await status_manager.handle_end_turn_hook(combat_main, self)
	if is_bloom():
		await trigger_ability(Plant.AbilityType.END_TURN)

func apply_weather_actions(weather_data:WeatherData) -> void:
	await apply_actions(weather_data.actions)

func apply_actions(actions:Array[ActionData]) -> void:
	#await _play_action_from_gui_animation(action, from_gui)
	for action in actions:
		match action.type:
			ActionData.ActionType.LIGHT:
				await _apply_light_action(action)
			ActionData.ActionType.WATER:
				await _apply_water_action(action)
			ActionData.ActionType.PEST, ActionData.ActionType.FUNGUS, ActionData.ActionType.RECYCLE, ActionData.ActionType.GREENHOUSE, ActionData.ActionType.SEEP:
				await _apply_field_status_action(action)
			_:
				pass
	action_application_completed.emit()

func apply_field_status(field_status_id:String, stack:int) -> void:
	var field_status_data:FieldStatusData = MainDatabase.field_status_database.get_data_by_id(field_status_id, true)
	if field_status_data.stackable:
		var text := str(stack)
		if stack > 0:
			text = "+" + str(stack)
		await _show_resource_icon_popup(field_status_id, text)
		status_manager.update_status(field_status_id, stack)
	else:
		var text := "+"
		if stack < 0:
			text = "-"
		await _show_resource_icon_popup(field_status_id, text)
		status_manager.update_status(field_status_id, 1)

func is_bloom() -> bool:
	return (light.max_value <=0 || light.is_full) && (water.max_value <=0 || water.is_full)

func bloom() -> void:
	fsm.push("PlantStateBloom")

func show_bloom_popup() -> void:
	_point_audio.play()
	# TODO:

#endregion

#region private functions
func _show_resource_icon_popup(icon_id:String, text:String) -> void:
	_buff_sound.play()
	var popup:PopupLabelIcon = POPUP_LABEL_ICON_SCENE.instantiate()
	var color:Color = Constants.COLOR_WHITE
	popup.setup(text, color, load(Util.get_image_path_for_resource_id(icon_id)))
	var popup_location:Vector2 = Util.get_node_canvas_position(self) + POPUP_OFFSET
	Events.request_display_popup_things.emit(popup, 6, 3, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, popup_location)
	await Util.create_scaled_timer(POPUP_SHOW_TIME).timeout

func _show_popup_action_indicator(action_data:ActionData, true_value:int) -> void:
	var text := str(true_value)
	if true_value > 0:
		text = "+" + text
	var resource_id := Util.get_action_id_with_action_type(action_data.type)
	await _show_resource_icon_popup(resource_id, text)

func _apply_light_action(action:ActionData) -> void:
	var true_value := _get_action_true_value(action)
	if action.operator_type == ActionData.OperatorType.EQUAL_TO:
		true_value = true_value - light.value 
	await _show_popup_action_indicator(action, true_value)
	light.value += true_value

func _apply_water_action(action:ActionData) -> void:
	var true_value := _get_action_true_value(action)
	if action.operator_type == ActionData.OperatorType.EQUAL_TO:
		true_value = true_value - water.value
	await _show_popup_action_indicator(action, true_value)
	water.value += true_value
	if true_value > 0:
		await status_manager.handle_add_water_hook(self)

func _apply_field_status_action(action:ActionData) -> void:
	var resource_id := Util.get_action_id_with_action_type(action.type)
	var true_value := _get_action_true_value(action)
	var current_status := status_manager.get_status(resource_id)
	if action.operator_type == ActionData.OperatorType.EQUAL_TO && current_status:
		true_value = true_value - current_status.stack
	await apply_field_status(resource_id, true_value)

func _get_action_true_value(action_data:ActionData) -> int:
	return action_data.get_calculated_value(self)

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

func _get_field() -> Field:
	return _weak_field.get_ref()

func _set_field(val:Field) -> void:
	_weak_field = weakref(val)

#endregion
