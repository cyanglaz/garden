class_name Plant
extends Node2D

const POPUP_LABEL_ICON_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label_icon.tscn")
const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")

const POPUP_SHOW_TIME := 0.3
const POPUP_DESTROY_TIME:= 1.2
const WIDTH := 32

enum AbilityType {
	HARVEST,
	END_DAY,
	LIGHT_GAIN,
	WEATHER,
	FIELD_STATUS_INCREASE,
	FIELD_STATUS_DECREASE,
	ON_PLANT,
}

signal action_application_completed()
@warning_ignore("unused_signal")
signal harvest_started()
@warning_ignore("unused_signal")
signal harvest_completed()
signal plant_hovered(hovered:bool)
signal plant_pressed()

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine
@onready var plant_ability_container: PlantAbilityContainer = %PlantAbilityContainer
@onready var _gui_plant_ability_icon_container: GUIPlantAbilityIconContainer = %GUIPlantAbilityIconContainer
@onready var _gui_field_status_container: GUIFieldStatusContainer = %GUIFieldStatusContainer
@onready var _gui_field_selection_arrow: GUIFieldSelectionArrow = %GUIFieldSelectionArrow
@onready var _light_bar: GUISegmentedProgressBar = %LightBar
@onready var _water_bar: GUISegmentedProgressBar = %WaterBar
@onready var _gui_plant_button: GUIBasicButton = %GUIPlantButton

@onready var _buff_sound: AudioStreamPlayer2D = %BuffSound
@onready var _plant_down_sound: AudioStreamPlayer2D = %PlantDownSound
@onready var _point_audio: AudioStreamPlayer2D = %PointAudio

var light:ResourcePoint = ResourcePoint.new()
var water:ResourcePoint = ResourcePoint.new()
var status_manager:FieldStatusManager = FieldStatusManager.new()

var data:PlantData:set = _set_data
var _tooltip_id:String = ""

func _ready() -> void:
	_light_bar.segment_color = Constants.LIGHT_THEME_COLOR
	_water_bar.segment_color = Constants.WATER_THEME_COLOR
	_light_bar.hide()
	_water_bar.hide()
	_gui_field_status_container.bind_with_field_status_manager(status_manager)
	status_manager.request_hook_message_popup.connect(_on_request_hook_message_popup)
	_gui_field_selection_arrow.indicator_state = GUIFieldSelectionArrow.IndicatorState.HIDE
	harvest_completed.connect(_on_plant_harvest_completed)
	_gui_plant_button.state_updated.connect(_on_gui_plant_button_state_updated)
	_gui_plant_button.pressed.connect(_on_plant_button_pressed)
	_gui_plant_button.mouse_entered.connect(_on_gui_plant_button_mouse_entered)
	_gui_plant_button.mouse_exited.connect(_on_gui_plant_button_mouse_exited)
	if plant_sprite.sprite_frames:
		plant_sprite.position.y = -plant_sprite.sprite_frames.get_frame_texture("idle", 0).get_height()/2.0

func plant_down(combat_main:CombatMain) -> void:
	_plant_down_sound.play()
	fsm.start()
	_show_progress_bars()
	_gui_plant_ability_icon_container.setup_with_plant(self)
	await trigger_ability(Plant.AbilityType.ON_PLANT, combat_main)

func can_harvest() -> bool:
	return is_grown()

func harvest(combat_main:CombatMain) -> void:
	fsm.push("PlantStateHarvest", {"combat_main": combat_main})

func trigger_ability(ability_type:AbilityType, combat_main:CombatMain) -> void:
	await plant_ability_container.trigger_ability(ability_type, combat_main, self)

func apply_weather_actions(weather_data:WeatherData, combat_main:CombatMain) -> void:
	await apply_actions(weather_data.actions, combat_main)
	await trigger_ability(Plant.AbilityType.WEATHER, combat_main)

func apply_actions(actions:Array[ActionData], combat_main:CombatMain) -> void:
	#await _play_action_from_gui_animation(action, from_gui)
	for action in actions:
		match action.type:
			ActionData.ActionType.LIGHT:
				await _apply_light_action(action, combat_main)
			ActionData.ActionType.WATER:
				await _apply_water_action(action, combat_main)
			ActionData.ActionType.PEST, ActionData.ActionType.FUNGUS, ActionData.ActionType.RECYCLE, ActionData.ActionType.GREENHOUSE, ActionData.ActionType.SEEP:
				await _apply_field_status_action(action, combat_main)
			_:
				pass
	action_application_completed.emit()

func apply_field_status(field_status_id:String, stack:int, combat_main:CombatMain) -> void:
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
	if stack > 0:
		await trigger_ability(Plant.AbilityType.FIELD_STATUS_INCREASE, combat_main)
	else:
		await trigger_ability(Plant.AbilityType.FIELD_STATUS_DECREASE, combat_main)

func handle_turn_end() -> void:
	status_manager.handle_status_on_turn_end()

func handle_tool_application_hook() -> void:
	await status_manager.handle_tool_application_hook(self)

func handle_tool_discard_hook(count:int) -> void:
	await status_manager.handle_tool_discard_hook(self, count)

func handle_end_day_hook(combat_main:CombatMain) -> void:
	await status_manager.handle_end_day_hook(combat_main, self)

func toggle_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState) -> void:
	_gui_field_selection_arrow.indicator_state = indicator_state

func show_tooltip() -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.PLANT, data, _tooltip_id, _gui_plant_button, false, GUITooltip.TooltipPosition.TOP, true)

func hide_tooltip() -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)

func show_harvest_popup() -> void:
	_point_audio.play()
	# TODO:

func get_preview_icon_global_position(preview_icon:Control) -> Vector2:
	return Util.get_node_canvas_position(_gui_plant_button) + Vector2.RIGHT * (_gui_plant_button.size.x/2 - preview_icon.size.x/2 ) + Vector2.UP * preview_icon.size.y/2

func is_grown() -> bool:
	return light.is_full && water.is_full

#region private methods

func _show_progress_bars() -> void:
	_light_bar.bind_with_resource_point(light)
	_water_bar.bind_with_resource_point(water)
	_light_bar.show()
	_water_bar.show()

func _show_resource_icon_popup(icon_id:String, text:String) -> void:
	_buff_sound.play()
	var popup:PopupLabelIcon = POPUP_LABEL_ICON_SCENE.instantiate()
	var color:Color = Constants.COLOR_WHITE
	popup.setup(text, color, load(Util.get_image_path_for_resource_id(icon_id)))
	var popup_location:Vector2 = Util.get_node_canvas_position(_gui_plant_button) + Vector2.RIGHT * 8
	Events.request_display_popup_things.emit(popup, 6, 3, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, popup_location)
	await Util.create_scaled_timer(POPUP_SHOW_TIME).timeout

func _show_popup_action_indicator(action_data:ActionData, true_value:int) -> void:
	var text := str(true_value)
	if true_value > 0:
		text = "+" + text
	var resource_id := Util.get_action_id_with_action_type(action_data.type)
	await _show_resource_icon_popup(resource_id, text)

func _apply_light_action(action:ActionData, combat_main:CombatMain) -> void:
	var true_value := _get_action_true_value(action)
	if action.operator_type == ActionData.OperatorType.EQUAL_TO:
		true_value = true_value - light.value 
	await _show_popup_action_indicator(action, true_value)
	light.value += true_value
	if true_value > 0:
		await trigger_ability(Plant.AbilityType.LIGHT_GAIN, combat_main)

func _apply_water_action(action:ActionData, combat_main:CombatMain) -> void:
	var true_value := _get_action_true_value(action)
	if action.operator_type == ActionData.OperatorType.EQUAL_TO:
		true_value = true_value - water.value
	await _show_popup_action_indicator(action, true_value)
	water.value += true_value
	if true_value > 0:
		await status_manager.handle_add_water_hook(combat_main, self)

func _apply_field_status_action(action:ActionData, combat_main:CombatMain) -> void:
	var resource_id := Util.get_action_id_with_action_type(action.type)
	var true_value := _get_action_true_value(action)
	var current_status := status_manager.get_status(resource_id)
	if action.operator_type == ActionData.OperatorType.EQUAL_TO && current_status:
		true_value = true_value - current_status.stack
	await apply_field_status(resource_id, true_value, combat_main)

func _get_action_true_value(action_data:ActionData) -> int:
	return action_data.get_calculated_value(self)

#endregion

func _set_data(value:PlantData) -> void:
	data = value
	light.setup(0, data.light)
	water.setup(0, data.water)
	plant_ability_container.setup_with_plant_data(data)

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
	var popup_location:Vector2 = Util.get_node_canvas_position(_gui_plant_button)
	Events.request_display_popup_things.emit(popup, 10, 1, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, popup_location)
	await Util.create_scaled_timer(POPUP_SHOW_TIME).timeout

func _on_plant_harvest_completed() -> void:
	await status_manager.handle_harvest_hook(self)

func _on_gui_plant_button_state_updated(state: GUIBasicButton.ButtonState) -> void:
	match state:
		GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.DISABLED, GUIBasicButton.ButtonState.SELECTED:
			plant_sprite.material.set_shader_parameter("outline_size", 0)
		GUIBasicButton.ButtonState.HOVERED:
			plant_sprite.material.set_shader_parameter("outline_size", 1)
		GUIBasicButton.ButtonState.PRESSED:
			plant_sprite.material.set_shader_parameter("outline_size", 0)

func _on_gui_plant_button_mouse_entered() -> void:
	Events.update_hovered_data.emit(data)
	plant_hovered.emit(true)

func _on_gui_plant_button_mouse_exited() -> void:
	Events.update_hovered_data.emit(null)
	plant_hovered.emit(false)

func _on_plant_button_pressed() -> void:
	plant_pressed.emit()
