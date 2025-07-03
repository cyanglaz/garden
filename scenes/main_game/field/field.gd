class_name Field
extends Node2D

const PLANT_SCENE_PATH_PREFIX := "res://scenes/plants/plants/plant_"

signal field_pressed()
signal field_hovered(hovered:bool)
signal tool_application_completed(tool_data:ToolData)
signal weather_application_completed(weather_data:WeatherData)
signal plant_harvest_gold_gained(gold:int)
signal plant_harvest_started()
signal plant_harvest_completed()

@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var _gui_field_button: GUIBasicButton = %GUIFieldButton
@onready var _light_bar: GUISegmentedProgressBar = %LightBar
@onready var _water_bar: GUISegmentedProgressBar = %WaterBar
@onready var _plant_container: Node2D = %PlantContainer
@onready var _progress_bars: VBoxContainer = %ProgressBars

var _weak_plant_preview:WeakRef = weakref(null)
var plant:Plant
var pest_count:int = 0
var fungus_count:int = 0

func _ready() -> void:
	_gui_field_button.state_updated.connect(_on_gui_field_button_state_updated)
	_gui_field_button.action_evoked.connect(func(): field_pressed.emit())
	_gui_field_button.mouse_entered.connect(func(): field_hovered.emit(true))
	_gui_field_button.mouse_exited.connect(func(): field_hovered.emit(false))
	_animated_sprite_2d.play("idle")
	_progress_bars.hide()
	_light_bar.segment_color = Constants.LIGHT_THEME_COLOR
	_water_bar.segment_color = Constants.WATER_THEME_COLOR

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
	plant.data = plant_data
	_plant_container.add_child(plant)
	_show_progress_bars(plant)
	plant.harvest_started.connect(_on_plant_harvest_started)
	plant.harvest_gold_gained.connect(_on_plant_harvest_gold_gained)
	plant.harvest_completed.connect(_on_plant_harvest_completed)

func get_preview_icon_global_position(reference_control:Control) -> Vector2:
	return Util.get_node_ui_position(reference_control, _gui_field_button) + Vector2.UP * 5 + Vector2.LEFT * 5

func remove_plant_preview() -> void:
	if _weak_plant_preview.get_ref():
		_weak_plant_preview.get_ref().queue_free()
		_progress_bars.hide()

func apply_tool(tool_data:ToolData) -> void:
	assert(plant, "No plant planted")
	for action:ActionData in tool_data.actions:
		match action.type:
			ActionData.ActionType.LIGHT:
				_apply_light_action(action)
			ActionData.ActionType.WATER:
				_apply_water_action(action)
			ActionData.ActionType.PEST:
				_apply_pest_action(action)
			ActionData.ActionType.FUNGUS:
				_apply_fungus_action(action)
			_:
				pass
	tool_application_completed.emit(tool_data)

func apply_weather_actions(weather_data:WeatherData) -> void:
	_apply_actions(weather_data.actions)
	weather_application_completed.emit(weather_data)

func can_harvest() -> bool:
	return plant && plant.can_harvest()

func harvest() -> void:
	assert(plant, "No plant planted")
	assert(can_harvest(), "Cannot harvest")
	plant.harvest()

func _apply_actions(actions:Array[ActionData]) -> void:
	for action:ActionData in actions:
		match action.type:
			ActionData.ActionType.LIGHT:
				_apply_light_action(action)
			ActionData.ActionType.WATER:
				_apply_water_action(action)
			ActionData.ActionType.PEST:
				_apply_pest_action(action)
			ActionData.ActionType.FUNGUS:
				_apply_fungus_action(action)
			_:
				pass

func _show_progress_bars(p:Plant) -> void:
	assert(p.data)
	_progress_bars.show()
	_light_bar.bind_with_resource_point(p.light)
	_water_bar.bind_with_resource_point(p.water)

func _hide_progress_bars() -> void:
	_progress_bars.hide()

func _apply_light_action(action:ActionData) -> void:
	if plant:
		plant.light.value += action.value

func _apply_water_action(action:ActionData) -> void:
	if plant:
		plant.water.value += action.value

func _apply_pest_action(action:ActionData) -> void:
	pest_count += action.value

func _apply_fungus_action(action:ActionData) -> void:
	fungus_count += action.value

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

func _on_plant_harvest_gold_gained(gold:int) -> void:
	plant_harvest_gold_gained.emit(gold)

func _on_plant_harvest_completed() -> void:
	plant.queue_free()
	plant = null
	plant_harvest_completed.emit()
	_hide_progress_bars()
