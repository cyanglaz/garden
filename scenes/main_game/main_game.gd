class_name MainGame
extends Node2D

@export var test_plant_datas:Array[PlantData]
@export var test_tools:Array[ToolData]
@export var number_of_fields := 0

@onready var gui_main_game: GUIMainGame = %GUIGameSession
@onready var _field_container: FieldContainer = %FieldContainer

var energy_tracker:ResourcePoint = ResourcePoint.new()
var week_manager:WeekManager = WeekManager.new()
var weather_manager:WeatherManager = WeatherManager.new()
var max_energy := 3
var _gold := 0

var _tools:Array[ToolData]
var _plant_seeds:Array[PlantData]
var _tool_selected := -1

func _ready() -> void:
	Singletons.main_game = self
	gui_main_game.plant_seed_deselected.connect(_on_plant_seed_deselected)
	gui_main_game.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui_main_game.tool_selected.connect(_on_tool_selected)
	gui_main_game.tool_selection_cleared.connect(_on_tool_selection_cleared)
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
	gui_main_game.update_with_plant_datas(_plant_seeds)
	gui_main_game.setup_tools(_tools)
	gui_main_game.bind_energy(energy_tracker)
	start_new_week()

func start_new_week() -> void:
	week_manager.next_week()
	weather_manager.generate_weathers(7, week_manager.week)
	gui_main_game.update_week(week_manager.week)
	gui_main_game.update_gold(_gold, false)
	gui_main_game.update_tax_due(week_manager.get_tax_due())
	start_day()

func start_day() -> void:
	energy_tracker.setup(max_energy, max_energy)
	week_manager.next_day()
	gui_main_game.update_weathers(weather_manager, week_manager.get_day())
	gui_main_game.set_day(week_manager.get_day())
	gui_main_game.clear_tool_selection()
	gui_main_game.toggle_all_ui(true)

func add_control_to_overlay(control:Control) -> void:
	gui_main_game.add_control_to_overlay(control)

func _end_turn() -> void:
	if week_manager.get_day() == 6:
		if _gold >= week_manager.get_tax_due():
			print("win")
		else:
			print("lose")
	else:
		start_day()

func _on_field_hovered(hovered:bool, index:int) -> void:
	var selected_plant_seed_data:PlantData = gui_main_game.selected_plant_seed_data
	if selected_plant_seed_data && !_field_container.is_field_occupied(index):
		if hovered:
			gui_main_game.pin_following_plant_icon_global_position(_field_container.get_preview_icon_global_position(gui_main_game.gui_mouse_following_plant_icon, index), Vector2.ONE * 0.8)
		else:
			gui_main_game.unpin_following_plant_icon()
		_field_container.toggle_plant_preview(hovered, selected_plant_seed_data, index)
	if _tool_selected > -1:
		var tool_data:ToolData = _tools[_tool_selected]
		var field := _field_container.fields[index]
		if hovered:
			field.toggle_selection_indicator(true, tool_data)
		else:
			field.toggle_selection_indicator(false, null)

func _on_plant_seed_deselected() -> void:
	_field_container.clear_previews()

func _on_field_pressed(index:int) -> void:
	var selected_plant_seed_data:PlantData = gui_main_game.selected_plant_seed_data
	var selected_tool_index:int = gui_main_game.selected_tool_card_index
	if selected_plant_seed_data && !_field_container.is_field_occupied(index):
		gui_main_game._on_plant_seed_selected(null)
		_field_container.plant_seed(selected_plant_seed_data, index)
	elif selected_tool_index > -1 && _field_container.is_field_occupied(index):
		var tool_data := _tools[selected_tool_index]
		gui_main_game.toggle_all_ui(false)
		_field_container.apply_tool(tool_data, index)

func _on_tool_selected(index:int) -> void:
	_tool_selected = index
	if _field_container.mouse_field:
		_field_container.mouse_field.toggle_selection_indicator(true, _tools[_tool_selected])

func _on_tool_selection_cleared() -> void:
	_tool_selected = -1
	_field_container.clear_tool_indicators()
	
func _on_field_tool_application_completed(_field_index:int, tool_data:ToolData) -> void:
	# Order matters, clear selection first then update tool data cd
	energy_tracker.spend(tool_data.energy_cost)
	gui_main_game.clear_tool_selection()
	gui_main_game.toggle_all_ui(true)

func _on_end_turn_button_pressed() -> void:
	gui_main_game.toggle_all_ui(false)
	await weather_manager.apply_weather_actions(week_manager.get_day(), _field_container.fields, gui_main_game.gui_weather_container.get_today_weather_icon())
	await _field_container.trigger_end_day_ability(weather_manager.get_current_weather(week_manager.get_day()), week_manager.get_day())
	_end_turn()
	
func _on_field_harvest_started() -> void:
	gui_main_game.toggle_all_ui(false)

func _on_field_harvest_completed() -> void:
	gui_main_game.toggle_all_ui(true)

func _on_field_harvest_gold_gained(gold:int) -> void:
	_gold += gold
	gui_main_game.update_gold(_gold, true)

func _on_energy_tracker_value_updated() -> void:
	gui_main_game.update_tool_for_energy(energy_tracker.value)
