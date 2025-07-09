class_name MainGame
extends Node2D

var hand_size := 5

@export var test_plant_datas:Array[PlantData]
@export var test_tools:Array[ToolData]
@export var number_of_fields := 0

@onready var gui_main_game: GUIMainGame = %GUIGameSession
@onready var _field_container: FieldContainer = %FieldContainer

var energy_tracker:ResourcePoint = ResourcePoint.new()
var week_manager:WeekManager = WeekManager.new()
var weather_manager:WeatherManager = WeatherManager.new()
var tool_manager:ToolManager
var plant_seed_manager:PlantSeedManager = PlantSeedManager.new()
var max_energy := 3
var _gold := 0

func _ready() -> void:
	Singletons.main_game = self
	gui_main_game.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui_main_game.tool_selected.connect(_on_tool_selected)
	gui_main_game.plant_seed_selected.connect(_on_plant_seed_selected)
	_field_container.update_with_number_of_fields(number_of_fields)
	_field_container.field_hovered.connect(_on_field_hovered)
	_field_container.field_pressed.connect(_on_field_pressed)
	_field_container.field_harvest_started.connect(_on_field_harvest_started)
	_field_container.field_harvest_completed.connect(_on_field_harvest_completed)
	weather_manager.weathers_updated.connect(_on_weathers_updated)
	
	if !test_plant_datas.is_empty():
		plant_seed_manager.plant_seeds = test_plant_datas
	if !test_tools.is_empty():
		tool_manager = ToolManager.new(test_tools)
		tool_manager.tool_application_started.connect(_on_tool_application_started)
		tool_manager.tool_application_completed.connect(_on_tool_application_completed)
		tool_manager.tool_application_failed.connect(_on_tool_application_failed)
	energy_tracker.can_be_capped = false
	energy_tracker.value_update.connect(_on_energy_tracker_value_updated)
	gui_main_game.update_with_plant_datas(plant_seed_manager.plant_seeds)
	gui_main_game.bind_energy(energy_tracker)
	start_new_week()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("de-select"):
		if tool_manager.selected_tool:
			_clear_tool_selection()
		_clear_plant_seed_selection()

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
	weather_manager.day = week_manager.get_day()
	gui_main_game.set_day(week_manager.get_day())
	gui_main_game.clear_tool_selection()
	await Util.await_for_tiny_time()
	await tool_manager.draw_cards(hand_size, gui_main_game.gui_tool_card_container)
	gui_main_game.toggle_all_ui(true)

func add_control_to_overlay(control:Control) -> void:
	gui_main_game.add_control_to_overlay(control)

#region private

func _end_turn() -> void:
	if week_manager.get_day() == 6:
		if _gold >= week_manager.get_tax_due():
			print("win")
		else:
			print("lose")
	else:
		start_day()

func _complete_tool_application(tool_data:ToolData) -> void:
	energy_tracker.spend(tool_data.energy_cost)
	_clear_tool_selection()
	gui_main_game.toggle_all_ui(true)

func _clear_tool_selection() -> void:
	tool_manager.select_tool(-1)
	gui_main_game.clear_tool_selection()
	_field_container.clear_tool_indicators()

func _clear_plant_seed_selection() -> void:
	plant_seed_manager.select_seed(-1)
	_field_container.clear_previews()
	gui_main_game.toggle_following_plant_icon_visibility(false, null)

#endregion

#region events

func _on_field_hovered(hovered:bool, index:int) -> void:
	var selected_plant_seed_data:PlantData = plant_seed_manager.selected_seed
	if selected_plant_seed_data && !_field_container.is_field_occupied(index):
		if hovered:
			gui_main_game.pin_following_plant_icon_global_position(_field_container.get_preview_icon_global_position(gui_main_game.gui_mouse_following_plant_icon, index), Vector2.ONE * 0.8)
		else:
			gui_main_game.unpin_following_plant_icon()
		_field_container.toggle_plant_preview(hovered, selected_plant_seed_data, index)
	if tool_manager.selected_tool:
		var field := _field_container.fields[index]
		if hovered && tool_manager.selected_tool.need_select_field:
			field.toggle_selection_indicator(true, tool_manager.selected_tool)
		else:
			field.toggle_selection_indicator(false, null)

func _on_field_pressed(index:int) -> void:
	var selected_plant_seed_data:PlantData = plant_seed_manager.selected_seed
	var field := _field_container.fields[index]
	if selected_plant_seed_data && !_field_container.is_field_occupied(index):
		# Plant seed
		_clear_plant_seed_selection()
		_field_container.plant_seed(selected_plant_seed_data, index)
	elif tool_manager.selected_tool:
		tool_manager.apply_tool(self, field)

func _on_plant_seed_selected(index:int) -> void:
	plant_seed_manager.select_seed(index)
	var plant_data:PlantData = plant_seed_manager.selected_seed
	if plant_data:
		gui_main_game.toggle_following_plant_icon_visibility(true, plant_data)
		_clear_tool_selection()
	else:
		_clear_plant_seed_selection()

func _on_tool_selected(index:int) -> void:
	if index < 0:
		_clear_tool_selection()
	else:
		_clear_plant_seed_selection()
	tool_manager.select_tool(index)
	var tool_data:ToolData = tool_manager.selected_tool
	if !tool_data:
		return
	if tool_data.need_select_field:
		if _field_container.mouse_field:
			_field_container.mouse_field.toggle_selection_indicator(true, tool_data)
	else:
		tool_manager.apply_tool(self, null)
	
func _on_tool_application_started() -> void:
	gui_main_game.toggle_all_ui(false)

func _on_tool_application_completed(tool_data:ToolData) -> void:
	_complete_tool_application(tool_data)

func _on_tool_application_failed() -> void:
	_clear_tool_selection()
	gui_main_game.toggle_all_ui(true)

func _on_end_turn_button_pressed() -> void:
	gui_main_game.toggle_all_ui(false)
	await weather_manager.apply_weather_actions(_field_container.fields, gui_main_game.gui_weather_container.get_today_weather_icon())
	await _field_container.trigger_end_day_ability(self)
	_end_turn()
	
func _on_field_harvest_started() -> void:
	gui_main_game.toggle_all_ui(false)

func _on_field_harvest_completed(gold:int) -> void:
	_gold += gold
	gui_main_game.update_gold(_gold, true)
	gui_main_game.toggle_all_ui(true)

func _on_energy_tracker_value_updated() -> void:
	gui_main_game.update_tool_for_energy(energy_tracker.value)

func _on_weathers_updated() -> void:
	gui_main_game.update_weathers(weather_manager)
#endregion
