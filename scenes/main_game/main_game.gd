class_name MainGame
extends Node2D

@export var test_plant_datas:Array[PlantData]
@export var test_tools:Array[ToolData]
@export var number_of_fields := 0

@onready var _field_container: FieldContainer = %FieldContainer
@onready var _gui_main_game: GUIMainGame = %GUIGameSession

var energy_tracker:ResourcePoint = ResourcePoint.new()
var week_manager:WeekManager = WeekManager.new()
var weather_manager:WeatherManager = WeatherManager.new()
var max_energy := 3
var _gold := 0

var _tools:Array[ToolData]
var _plant_seeds:Array[PlantData]

func _ready() -> void:
	Singletons.main_game = self
	_gui_main_game.plant_seed_deselected.connect(_on_plant_seed_deselected)
	_gui_main_game.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	_field_container.update_with_number_of_fields(number_of_fields)
	_field_container.field_hovered.connect(_on_field_hovered)
	_field_container.field_pressed.connect(_on_field_pressed)
	_field_container.field_tool_application_completed.connect(_on_field_tool_application_completed)
	_field_container.field_harvest_started.connect(_on_field_harvest_started)
	_field_container.field_harvest_completed.connect(_on_field_harvest_completed)
	_field_container.field_harvest_gold_gained.connect(_on_field_harvest_gold_gained)
	
	if !test_plant_datas.is_empty():
		_plant_seeds = test_plant_datas
	if !test_tools.is_empty():
		_tools = test_tools
	energy_tracker.can_be_capped = false
	energy_tracker.value_update.connect(_on_energy_tracker_value_updated)
	_gui_main_game.update_with_plant_datas(_plant_seeds)
	_gui_main_game.setup_tools(_tools)
	_gui_main_game.bind_energy(energy_tracker)
	start_new_week()

func start_new_week() -> void:
	week_manager.next_week()
	weather_manager.generate_weathers(7, week_manager.week)
	_gui_main_game.update_week(week_manager.week)
	_gui_main_game.update_gold(_gold, false)
	_gui_main_game.update_tax_due(week_manager.get_tax_due())
	start_day()

func start_day() -> void:
	energy_tracker.setup(max_energy, max_energy)
	week_manager.next_day()
	_gui_main_game.update_weathers(weather_manager, week_manager.get_day())
	_gui_main_game.set_day(week_manager.get_day())
	_gui_main_game.clear_tool_selection()
	_gui_main_game.toggle_all_ui(true)

func add_control_to_overlay(control:Control) -> void:
	_gui_main_game.add_control_to_overlay(control)

func _end_turn() -> void:
	if week_manager.get_day() == 6:
		if _gold >= week_manager.get_tax_due():
			print("win")
		else:
			print("lose")
	else:
		start_day()

func _on_field_hovered(hovered:bool, index:int) -> void:
	var selected_plant_seed_data:PlantData = _gui_main_game.selected_plant_seed_data
	if selected_plant_seed_data && !_field_container.is_field_occupied(index):
		if hovered:
			_gui_main_game.pin_following_plant_icon_global_position(_field_container.get_preview_icon_global_position(_gui_main_game.get_child(0), index), Vector2.ONE * 0.8)
		else:
			_gui_main_game.unpin_following_plant_icon()
		_field_container.toggle_plant_preview(hovered, selected_plant_seed_data, index)

func _on_plant_seed_deselected() -> void:
	_field_container.clear_previews()

func _on_field_pressed(index:int) -> void:
	var selected_plant_seed_data:PlantData = _gui_main_game.selected_plant_seed_data
	var selected_tool_index:int = _gui_main_game.selected_tool_card_index
	if selected_plant_seed_data && !_field_container.is_field_occupied(index):
		_gui_main_game._on_plant_seed_selected(null)
		_field_container.plant_seed(selected_plant_seed_data, index)
	elif selected_tool_index > -1 && _field_container.is_field_occupied(index):
		var tool_data := _tools[selected_tool_index]
		_gui_main_game.toggle_all_ui(false)
		_field_container.apply_tool(tool_data, index)

func _on_field_tool_application_completed(_field_index:int, tool_data:ToolData) -> void:
	# Order matters, clear selection first then update tool data cd
	energy_tracker.spend(tool_data.energy_cost)
	_gui_main_game.clear_tool_selection()
	_gui_main_game.toggle_all_ui(true)

func _on_end_turn_button_pressed() -> void:
	_gui_main_game.toggle_all_ui(false)
	await weather_manager.apply_weather_actions(week_manager.get_day(), _field_container.fields, _gui_main_game.gui_weather_container.get_today_weather_icon())
	_end_turn()
	
func _on_field_harvest_started() -> void:
	_gui_main_game.toggle_all_ui(false)

func _on_field_harvest_completed() -> void:
	_gui_main_game.toggle_all_ui(true)

func _on_field_harvest_gold_gained(gold:int) -> void:
	_gold += gold
	_gui_main_game.update_gold(_gold, true)

func _on_energy_tracker_value_updated() -> void:
	_gui_main_game.update_tool_for_energy(energy_tracker.value)
