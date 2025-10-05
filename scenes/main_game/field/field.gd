class_name Field
extends Node2D

const PLANT_SCENE_PATH_PREFIX := "res://scenes/main_game/plants/plants/plant_"
const POPUP_LABEL_ICON_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label_icon.tscn")
const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")
const point_LABEL_OFFSET := Vector2.RIGHT * 12
const POPUP_SHOW_TIME := 0.3
const POPUP_DESTROY_TIME:= 0.8
const POPUP_STATUS_DESTROY_TIME := 1.2

signal field_pressed()
signal field_hovered(hovered:bool)
signal action_application_completed()
signal plant_harvest_started()
signal plant_harvest_completed()
signal new_plant_planted()

@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _gui_field_button: GUIBasicButton = %GUIFieldButton
@onready var _light_bar: GUISegmentedProgressBar = %LightBar
@onready var _water_bar: GUISegmentedProgressBar = %WaterBar
@onready var _plant_container: Node2D = %PlantContainer
@onready var _buff_sound: AudioStreamPlayer2D = %BuffSound
@onready var _point_audio: AudioStreamPlayer2D = %PointAudio
@onready var _gui_field_selection_arrow: GUIFieldSelectionArrow = %GUIFieldSelectionArrow
@onready var _gui_field_status_container: GUIFieldStatusContainer = %GUIFieldStatusContainer
@onready var _gui_plant_ability_icon_container: GUIPlantAbilityIconContainer = %GUIPlantAbilityIconContainer
@onready var _plant_down_sound: AudioStreamPlayer2D = %PlantDownSound

var _weak_plant_preview:WeakRef = weakref(null)
var plant:Plant
var status_manager:FieldStatusManager = FieldStatusManager.new()
var weak_left_field:WeakRef = weakref(null)
var weak_right_field:WeakRef = weakref(null)

var _weak_plant_tooltip = weakref(null)

func _ready() -> void:
	_gui_field_button.state_updated.connect(_on_gui_field_button_state_updated)
	_gui_field_button.pressed.connect(_on_gui_field_button_pressed)
	_gui_field_button.mouse_entered.connect(_on_field_mouse_entered)
	_gui_field_button.mouse_exited.connect(_on_field_mouse_exited)
	_gui_field_status_container.bind_with_field_status_manager(status_manager)
	status_manager.request_hook_message_popup.connect(_on_request_hook_message_popup)
	#status_manager.update_status("pest", 1)
	_animated_sprite_2d.play("idle")
	_light_bar.segment_color = Constants.LIGHT_THEME_COLOR
	_water_bar.segment_color = Constants.WATER_THEME_COLOR
	_gui_field_selection_arrow.indicator_state = GUIFieldSelectionArrow.IndicatorState.HIDE
	_reset_progress_bars()

func toggle_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState) -> void:
	_gui_field_selection_arrow.indicator_state = indicator_state
 
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
	_plant_down_sound.play()
	var plant_scene_path := PLANT_SCENE_PATH_PREFIX + plant_data.id + ".tscn"
	var scene := load(plant_scene_path)
	plant = scene.instantiate()
	_plant_container.add_child(plant)
	plant.data = plant_data
	_show_progress_bars(plant)
	plant.harvest_started.connect(func(): plant_harvest_started.emit())
	plant.harvest_completed.connect(_on_plant_harvest_completed)
	plant.field = self
	_gui_plant_ability_icon_container.setup_with_plant(plant)
	await plant.trigger_ability(Plant.AbilityType.ON_PLANT, Singletons.main_game)
	new_plant_planted.emit()

func remove_plant() -> void:
	if plant:
		_gui_plant_ability_icon_container.remove_all()
		plant.removed_from_field.emit()
		plant.queue_free()
		plant = null

func get_preview_icon_global_position(preview_icon:Control) -> Vector2:
	return Util.get_node_ui_position(preview_icon, _gui_field_button) + Vector2.RIGHT * (_gui_field_button.size.x/2 - preview_icon.size.x/2 ) + Vector2.UP * preview_icon.size.y/2

func remove_plant_preview() -> void:
	if _weak_plant_preview.get_ref():
		_weak_plant_preview.get_ref().queue_free()
		_reset_progress_bars()

func apply_weather_actions(weather_data:WeatherData) -> void:
	await apply_actions(weather_data.actions)
	if plant:
		await plant.trigger_ability(Plant.AbilityType.WEATHER, Singletons.main_game)

func is_action_applicable(action:ActionData) -> bool:
	if action.type == ActionData.ActionType.LIGHT || action.type == ActionData.ActionType.WATER:
		return plant != null
	else:
		return true

func apply_actions(actions:Array[ActionData]) -> void:
	for action:ActionData in actions:
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
	if plant:
		if stack > 0:
			await plant.trigger_ability(Plant.AbilityType.FIELD_STATUS_INCREASE, Singletons.main_game)
		else:
			await plant.trigger_ability(Plant.AbilityType.FIELD_STATUS_DECREASE, Singletons.main_game)

func show_harvest_popup() -> void:
	_point_audio.play()
	# TODO:

func can_harvest() -> bool:
	return plant && plant.can_harvest()

func harvest() -> void:
	assert(plant, "No plant planted")
	assert(can_harvest(), "Cannot harvest")
	plant.harvest()

func handle_turn_end() -> void:
	status_manager.handle_status_on_turn_end()

func handle_tool_application_hook() -> void:
	await status_manager.handle_tool_application_hook(plant)

func handle_tool_discard_hook(count:int) -> void:
	await status_manager.handle_tool_discard_hook(plant, count)

func handle_end_day_hook(main_game:MainGame) -> void:
	await status_manager.handle_end_day_hook(main_game, plant)

func clear_all_statuses() -> void:
	status_manager.clear_all_statuses()

func _show_progress_bars(p:Plant) -> void:
	assert(p.data)
	_light_bar.bind_with_resource_point(p.light)
	_water_bar.bind_with_resource_point(p.water)

func _reset_progress_bars() -> void:
	_light_bar.max_value = 0
	_light_bar.current_value = 0
	_water_bar.max_value = 0
	_water_bar.current_value = 0

func _apply_light_action(action:ActionData) -> void:
	var true_value := _get_action_true_value(action)
	await _show_popup_action_indicator(action, true_value)
	if plant:
		plant.light.value += true_value
		if true_value > 0:
			await plant.trigger_ability(Plant.AbilityType.LIGHT_GAIN, Singletons.main_game)

func _apply_water_action(action:ActionData) -> void:
	var true_value := _get_action_true_value(action)
	await _show_popup_action_indicator(action, true_value)
	if plant:
		plant.water.value += true_value
		if true_value > 0:
			await status_manager.handle_add_water_hook(plant)

func _apply_field_status_action(action:ActionData) -> void:
	var resource_id := Util.get_action_id_with_action_type(action.type)
	var true_value := _get_action_true_value(action)
	await apply_field_status(resource_id, true_value)

func _show_popup_action_indicator(action_data:ActionData, true_value:int) -> void:
	var text := str(true_value)
	if true_value > 0:
		text = "+" + text
	var resource_id := Util.get_action_id_with_action_type(action_data.type)
	await _show_resource_icon_popup(resource_id, text)

func _show_resource_icon_popup(icon_id:String, text:String) -> void:
	_buff_sound.play()
	var popup:PopupLabelIcon = POPUP_LABEL_ICON_SCENE.instantiate()
	add_child(popup)
	popup.global_position = _gui_field_button.global_position + _gui_field_button.size/2 + Vector2.RIGHT * 8
	var color:Color = Constants.COLOR_WHITE
	popup.setup(text, color, load(Util.get_image_path_for_resource_id(icon_id)))
	await popup.animate_show_and_destroy(6, 3, POPUP_SHOW_TIME, POPUP_DESTROY_TIME)

func _get_action_true_value(action_data:ActionData) -> int:
	if action_data.value_type == ActionData.ValueType.NUMBER:
		return action_data.value
	elif action_data.value_type == ActionData.ValueType.NUMBER_OF_TOOL_CARDS_IN_HAND:
		return Singletons.main_game.tool_manager.tool_deck.hand.size()
	return 0

func _on_gui_field_button_state_updated(state: GUIBasicButton.ButtonState) -> void:
	match state:
		GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.DISABLED, GUIBasicButton.ButtonState.SELECTED:
			_animated_sprite_2d.play("idle")
		GUIBasicButton.ButtonState.HOVERED:
			_animated_sprite_2d.play("hover")
		GUIBasicButton.ButtonState.PRESSED:
			_animated_sprite_2d.play("pressed")

func _on_plant_harvest_completed() -> void:
	await status_manager.handle_harvest_hook(plant)
	_reset_progress_bars()
	plant_harvest_completed.emit()

func _on_request_hook_message_popup(status_data:FieldStatusData) -> void:
	var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	add_child(popup)
	popup.global_position = _gui_field_button.global_position
	var color:Color = Constants.COLOR_RED2
	match status_data.type:
		FieldStatusData.Type.BAD:
			color = Constants.COLOR_RED2
		FieldStatusData.Type.GOOD:
			color = Constants.COLOR_YELLOW2
	popup.animate_show_label_and_destroy(status_data.popup_message, 10, 1, POPUP_SHOW_TIME, POPUP_STATUS_DESTROY_TIME, color)

func _on_field_mouse_entered() -> void:
	if plant:
		Singletons.main_game.hovered_data = plant.data
		field_hovered.emit(true)
		if !Singletons.main_game.tool_manager.selected_tool:
			_weak_plant_tooltip = weakref(Util.display_plant_tooltip(plant.data, _gui_field_button, false, GUITooltip.TooltipPosition.LEFT_TOP, true))

func _on_field_mouse_exited() -> void:
	Singletons.main_game.hovered_data = null
	field_hovered.emit(false)
	if _weak_plant_tooltip.get_ref():
		_weak_plant_tooltip.get_ref().queue_free()

func _on_gui_field_button_pressed() -> void:
	if plant:
		field_pressed.emit()
