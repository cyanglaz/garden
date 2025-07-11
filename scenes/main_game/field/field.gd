class_name Field
extends Node2D

const PLANT_SCENE_PATH_PREFIX := "res://scenes/main_game/plants/plants/plant_"
const POPUP_LABEL_ICON_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label_icon.tscn")
const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")
const GOLD_ICON := preload("res://resources/sprites/GUI/icons/resources/icon_gold.png")
const GOLD_LABEL_OFFSET := Vector2.RIGHT * 12
const POPUP_GOLD_SHOW_TIME := 0.5
const POPUP_GOLD_DESTROY_TIME := 1.0
const POPUP_SHOW_TIME := 0.2
const POPUP_DESTROY_TIME:= 0.8
const POPUP_STATUS_DESTROY_TIME := 1.2

signal field_pressed()
signal field_hovered(hovered:bool)
signal tool_application_completed(tool_data:ToolData)
signal plant_harvest_started()
signal plant_harvest_completed(gold:int)

@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _gui_field_button: GUIBasicButton = %GUIFieldButton
@onready var _light_bar: GUISegmentedProgressBar = %LightBar
@onready var _water_bar: GUISegmentedProgressBar = %WaterBar
@onready var _plant_container: Node2D = %PlantContainer
@onready var _buff_sound: AudioStreamPlayer2D = %BuffSound
@onready var _gold_audio: AudioStreamPlayer2D = %GoldAudio
@onready var _gui_field_selection_arrow: GUIFieldSelectionArrow = %GUIFieldSelectionArrow
@onready var _gui_field_status_container: GUIFieldStatusContainer = %GUIFieldStatusContainer

var _weak_plant_preview:WeakRef = weakref(null)
var plant:Plant
var status_manager:FieldStatusManager = FieldStatusManager.new()
var weak_left_field:WeakRef = weakref(null)
var weak_right_field:WeakRef = weakref(null)

func _ready() -> void:
	_gui_field_button.state_updated.connect(_on_gui_field_button_state_updated)
	_gui_field_button.action_evoked.connect(func(): field_pressed.emit())
	_gui_field_button.mouse_entered.connect(func(): field_hovered.emit(true))
	_gui_field_button.mouse_exited.connect(func(): field_hovered.emit(false))
	_gui_field_status_container.bind_with_field_status_manager(status_manager)
	status_manager.request_hook_message_popup.connect(_on_request_hook_message_popup)
	status_manager.update_status("pest", 2)
	_animated_sprite_2d.play("idle")
	_light_bar.segment_color = Constants.LIGHT_THEME_COLOR
	_water_bar.segment_color = Constants.WATER_THEME_COLOR
	_gui_field_selection_arrow.is_active = false
	_reset_progress_bars()

func toggle_selection_indicator(on:bool, tool_data:ToolData) -> void:
	_gui_field_selection_arrow.is_active = on
	if tool_data:
		assert(on)
		_gui_field_selection_arrow.is_enabled = is_tool_applicable(tool_data)
 
func show_plant_preview(plant_data:PlantData) -> void:
	var plant_scene_path := PLANT_SCENE_PATH_PREFIX + plant_data.id + ".tscn"
	var scene := load(plant_scene_path)
	var plant_preview:Plant = scene.instantiate()
	plant_preview.data = plant_data
	_plant_container.add_child(plant_preview)
	plant_preview.show_as_preview()
	_weak_plant_preview = weakref(plant_preview)
	_show_progress_bars(plant_preview)

func plant_seed(plant_data:PlantData) -> void:
	assert(plant == null, "Plant already planted")
	var plant_scene_path := PLANT_SCENE_PATH_PREFIX + plant_data.id + ".tscn"
	var scene := load(plant_scene_path)
	plant = scene.instantiate()
	plant.data = plant_data.get_duplicate()
	_plant_container.add_child(plant)
	_show_progress_bars(plant)
	plant.harvest_started.connect(_on_plant_harvest_started)
	plant.harvest_completed.connect(_on_plant_harvest_completed.bind(plant))
	plant.field = self

func get_preview_icon_global_position(preview_icon:Control) -> Vector2:
	return Util.get_node_ui_position(preview_icon, _gui_field_button) + Vector2.UP * 8

func remove_plant_preview() -> void:
	if _weak_plant_preview.get_ref():
		_weak_plant_preview.get_ref().queue_free()
		_reset_progress_bars()

func apply_tool(tool_data:ToolData) -> void:
	await apply_actions(tool_data.actions)
	tool_application_completed.emit(tool_data)

func apply_weather_actions(weather_data:WeatherData) -> void:
	await apply_actions(weather_data.actions)

func is_action_applicable(action:ActionData) -> bool:
	if action.type == ActionData.ActionType.PEST || action.type == ActionData.ActionType.FUNGUS:
		return true
	elif plant:
		return true
	return false

func apply_actions(actions:Array[ActionData]) -> void:
	for action:ActionData in actions:
		match action.type:
			ActionData.ActionType.LIGHT:
				await _apply_light_action(action)
			ActionData.ActionType.WATER:
				await _apply_water_action(action)
			ActionData.ActionType.PEST:
				await _apply_pest_action(action)
			ActionData.ActionType.FUNGUS:
				await _apply_fungus_action(action)
			_:
				pass
	if _can_harvest():
		_harvest()

func show_gold_popup() -> void:
	_gold_audio.play()
	var gold_label:PopupLabelIcon = POPUP_LABEL_ICON_SCENE.instantiate()
	add_child(gold_label)
	gold_label.global_position = _gui_field_button.global_position + _gui_field_button.size/2 + Vector2.LEFT * 16
	var color:Color = Constants.COLOR_YELLOW2
	gold_label.setup(str("+", plant.data.gold), color, GOLD_ICON)
	await gold_label.animate_show_and_destroy(8, 6, POPUP_GOLD_SHOW_TIME, POPUP_GOLD_DESTROY_TIME)

func _can_harvest() -> bool:
	return plant && plant.can_harvest()

func _harvest() -> void:
	assert(plant, "No plant planted")
	assert(_can_harvest(), "Cannot harvest")
	plant.harvest()

func _show_progress_bars(p:Plant) -> void:
	assert(p.data)
	_light_bar.bind_with_resource_point(p.light)
	_water_bar.bind_with_resource_point(p.water)

func _reset_progress_bars() -> void:
	_light_bar.max_value = 1
	_light_bar.current_value = 0
	_water_bar.max_value = 1
	_water_bar.current_value = 0

func is_tool_applicable(tool_data:ToolData) -> bool:
	for action_data:ActionData in tool_data.actions:
		if is_action_applicable(action_data):
			return true
	return false

func _apply_light_action(action:ActionData) -> void:
	if plant:
		await _show_popup_action_indicator(action)
		plant.light.value += action.value

func _apply_water_action(action:ActionData) -> void:
	if plant:
		await _show_popup_action_indicator(action)
		plant.water.value += action.value

func _apply_pest_action(action:ActionData) -> void:
	await _show_popup_action_indicator(action)
	status_manager.update_status("pest", action.value)

func _apply_fungus_action(action:ActionData) -> void:
	await _show_popup_action_indicator(action)
	status_manager.update_status("fungus", action.value)

func _show_popup_action_indicator(action_data:ActionData) -> void:
	_buff_sound.play()
	var popup:PopupLabelIcon = POPUP_LABEL_ICON_SCENE.instantiate()
	add_child(popup)
	popup.global_position = _gui_field_button.global_position + _gui_field_button.size/2 + Vector2.RIGHT * 8
	var text := str(action_data.value)
	if action_data.value > 0:
		text = "+" + text
	popup.setup(text, Constants.COLOR_WHITE, Util.get_action_icon_with_action_type(action_data.type))
	await popup.animate_show_and_destroy(6, 3, POPUP_SHOW_TIME, POPUP_DESTROY_TIME)

func _on_gui_field_button_state_updated(state: GUIBasicButton.ButtonState) -> void:
	match state:
		GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.DISABLED, GUIBasicButton.ButtonState.SELECTED:
			_animated_sprite_2d.play("idle")
		GUIBasicButton.ButtonState.HOVERED:
			_animated_sprite_2d.play("hover")
		GUIBasicButton.ButtonState.PRESSED:
			_animated_sprite_2d.play("pressed")

func _on_plant_harvest_started() -> void:
	plant_harvest_started.emit()

func _on_plant_harvest_completed(p:Plant) -> void:
	plant_harvest_completed.emit(p.data.gold)
	plant.queue_free()
	plant = null
	_reset_progress_bars()

func _on_request_hook_message_popup(status_data:FieldStatusData) -> void:
	var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	add_child(popup)
	popup.global_position = _gui_field_button.global_position
	var color:Color = Constants.COLOR_RED2
	match status_data.type:
		FieldStatusData.Type.BAD:
			color = Constants.COLOR_RED2
		FieldStatusData.Type.GOOD:
			color = Constants.COLOR_GREEN2
	popup.animate_show_label_and_destroy(status_data.popup_message, 18, 1, POPUP_SHOW_TIME, POPUP_STATUS_DESTROY_TIME, color)
