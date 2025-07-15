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
var plant_seed_manager:PlantSeedManager
var max_energy := 3
var _gold := 0

func _ready() -> void:
	Singletons.main_game = self
	gui_main_game.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui_main_game.tool_selected.connect(_on_tool_selected)
	_field_container.update_with_number_of_fields(number_of_fields)
	_field_container.field_hovered.connect(_on_field_hovered)
	_field_container.field_pressed.connect(_on_field_pressed)
	_field_container.field_harvest_started.connect(_on_field_harvest_started)
	_field_container.field_harvest_gold_update_requested.connect(_on_field_harvest_gold_update_requested)
	weather_manager.weathers_updated.connect(_on_weathers_updated)
	
	if !test_plant_datas.is_empty():
		plant_seed_manager = PlantSeedManager.new(test_plant_datas)
	if !test_tools.is_empty():
		test_tools.append_array(test_tools)
		#test_tools.append_array(test_tools)
		tool_manager = ToolManager.new(test_tools)
		tool_manager.tool_application_started.connect(_on_tool_application_started)
		tool_manager.tool_application_completed.connect(_on_tool_application_completed)
		tool_manager.tool_application_failed.connect(_on_tool_application_failed)
	energy_tracker.can_be_capped = false
	gui_main_game.bind_energy(energy_tracker)
	gui_main_game.bind_tool_deck(tool_manager.tool_deck)
	gui_main_game.bind_plant_seed_deck(plant_seed_manager.plant_deck)
	gui_main_game.setup_plant_seed_animation_container(_field_container)
	start_new_week()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("de-select"):
		if tool_manager.selected_tool:
			_clear_tool_selection()

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
	await draw_cards(hand_size)
	var unoccupied_fields:Array[int] = _field_container.get_unoccupied_fields()
	if unoccupied_fields.size() > 0:
		await Util.create_scaled_timer(0.2).timeout # If planting is needed, there would be a gold update animation, wait for that animationg to end before drawing new plants
		await plant_seed_manager.draw_cards(unoccupied_fields.size(), gui_main_game.gui_plant_seed_animation_container, unoccupied_fields, _field_container)
	gui_main_game.toggle_all_ui(true)

func add_control_to_overlay(control:Control) -> void:
	gui_main_game.add_control_to_overlay(control)

func draw_cards(count:int) -> void:
	await tool_manager.draw_cards(count, gui_main_game.gui_tool_card_container)

#region private

func _end_turn() -> void:
	if week_manager.get_day() == 6:
		if _gold >= week_manager.get_tax_due():
			print("win")
		else:
			print("lose")
	else:
		start_day()
	
func _discard_all_tools() -> void:
	var discarding_indices:Array[int] = []
	for i in tool_manager.tool_deck.hand.size():
		discarding_indices.append(i)
	await tool_manager.discard_cards(discarding_indices, gui_main_game.gui_tool_card_container)

func _clear_tool_selection() -> void:
	tool_manager.select_tool(-1)
	gui_main_game.clear_tool_selection()
	_field_container.clear_tool_indicators()

#endregion

#region events

func _on_field_hovered(hovered:bool, index:int) -> void:
	if tool_manager.selected_tool:
		var field := _field_container.fields[index]
		if hovered && tool_manager.selected_tool.need_select_field:
			field.toggle_selection_indicator(true, tool_manager.selected_tool)
		else:
			field.toggle_selection_indicator(false, null)

func _on_field_pressed(index:int) -> void:
	var field := _field_container.fields[index]
	if tool_manager.selected_tool:
		await tool_manager.apply_tool(self, field)

func _on_tool_selected(index:int) -> void:
	_field_container.clear_tool_indicators()
	tool_manager.select_tool(index)
	var tool_data:ToolData = tool_manager.selected_tool
	if !tool_data:
		return
	if tool_data.need_select_field:
		if _field_container.mouse_field:
			_field_container.mouse_field.toggle_selection_indicator(true, tool_data)
	else:
		await tool_manager.apply_tool(self, null)
	
func _on_tool_application_started(index:int) -> void:
	gui_main_game.toggle_all_ui(false)
	var tool_data:ToolData = tool_manager.get_tool(index)
	await tool_manager.discard_cards([index], gui_main_game.gui_tool_card_container)
	_clear_tool_selection()
	energy_tracker.spend(tool_data.energy_cost)

func _on_tool_application_completed(_index:int) -> void:
	gui_main_game.toggle_all_ui(true)

func _on_tool_application_failed(_index:int) -> void:
	_clear_tool_selection()
	gui_main_game.toggle_all_ui(true)

func _on_end_turn_button_pressed() -> void:
	gui_main_game.toggle_all_ui(false)
	await _discard_all_tools()
	await weather_manager.apply_weather_actions(_field_container.fields, gui_main_game.gui_weather_container.get_today_weather_icon())
	await _field_container.trigger_end_day_ability(self)
	_end_turn()
	
func _on_field_harvest_started() -> void:
	gui_main_game.toggle_all_ui(false)

func _on_field_harvest_gold_update_requested(gold:int, index:int) -> void:
	_gold += gold
	await plant_seed_manager.discard_cards([index], gui_main_game.gui_plant_seed_animation_container)
	await gui_main_game.update_gold(_gold, true)
	await plant_seed_manager.draw_cards(1, gui_main_game.gui_plant_seed_animation_container, [index], _field_container)

func _on_weathers_updated() -> void:
	gui_main_game.update_weathers(weather_manager)
#endregion
