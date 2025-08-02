class_name MainGame
extends Node2D

signal _all_field_gold_gained()

var hand_size := 5
const DAYS_TO_WEEK := 7

@export var test_plant_datas:Array[PlantData]
@export var test_tools:Array[ToolData]
@export var number_of_fields := 0

@onready var gui_main_game: GUIMainGame = %GUIGameSession
@onready var field_container: FieldContainer = %FieldContainer

var session_seed := 0

var energy_tracker:ResourcePoint = ResourcePoint.new()
var week_manager:WeekManager = WeekManager.new()
var weather_manager:WeatherManager = WeatherManager.new()
var tool_manager:ToolManager
var plant_seed_manager:PlantSeedManager
var max_energy := 3
var _gold := 0: set = _set_gold

var _harvesting_fields:Array = []
var _gold_gaining_fields:Array = []

func _ready() -> void:
	Singletons.main_game = self
	
	#field signals
	field_container.update_with_number_of_fields(number_of_fields)
	field_container.field_hovered.connect(_on_field_hovered)
	field_container.field_pressed.connect(_on_field_pressed)
	field_container.field_harvest_started.connect(_on_field_harvest_started)
	field_container.field_harvest_gold_update_requested.connect(_on_field_harvest_gold_update_requested)
	
	#weather signals
	weather_manager.weathers_updated.connect(_on_weathers_updated)
	
	if !test_plant_datas.is_empty():
		plant_seed_manager = PlantSeedManager.new(test_plant_datas)
	if !test_tools.is_empty():
		#test_tools.append_array(test_tools)
		#test_tools.append_array(test_tools)
		
		#tool signals
		tool_manager = ToolManager.new(test_tools)
		tool_manager.tool_application_started.connect(_on_tool_application_started)
		tool_manager.tool_application_completed.connect(_on_tool_application_completed)
		
	#gui main signals
	gui_main_game.bind_energy(energy_tracker)
	gui_main_game.bind_tool_deck(tool_manager.tool_deck)
	gui_main_game.bind_plant_seed_deck(plant_seed_manager.plant_deck)
	gui_main_game.setup_plant_seed_animation_container(field_container)
	gui_main_game.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui_main_game.tool_selected.connect(_on_tool_selected)
	gui_main_game.week_summary_continue_button_pressed.connect(_on_week_summary_continue_button_pressed)
	
	#shop signals
	gui_main_game.gui_shop_main.next_week_button_pressed.connect(_on_shop_next_week_pressed)
	gui_main_game.gui_shop_main.plant_shop_button_pressed.connect(_on_plant_shop_button_pressed)
	gui_main_game.gui_shop_main.tool_shop_button_pressed.connect(_on_tool_shop_button_pressed)
	
	energy_tracker.can_be_capped = false
	start_new_week()
	_update_gold(50, false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("de-select"):
		if tool_manager.selected_tool:
			_clear_tool_selection()

func start_new_week() -> void:
	tool_manager.refresh_deck()
	plant_seed_manager.refresh_deck()
	week_manager.next_week()
	weather_manager.generate_weathers(7, week_manager.week)
	gui_main_game.update_week(week_manager.week)
	start_day()

func start_day() -> void:
	gui_main_game.toggle_all_ui(false)
	energy_tracker.setup(max_energy, max_energy)
	week_manager.next_day()
	weather_manager.day = week_manager.get_day()
	gui_main_game.set_day(week_manager.get_day())
	gui_main_game.clear_tool_selection()
	await Util.await_for_tiny_time()
	if week_manager.get_day() == 0:
		await Util.create_scaled_timer(0.2).timeout
		await gui_main_game.update_tax_due(week_manager.get_tax_due())
		await _plant_new_seeds()
	await draw_cards(hand_size)
	gui_main_game.toggle_all_ui(true)

func add_control_to_overlay(control:Control) -> void:
	gui_main_game.add_control_to_overlay(control)

func draw_cards(count:int) -> void:
	await tool_manager.draw_cards(count, gui_main_game.gui_tool_card_container)

func discard_cards(indices:Array) -> void:
	await tool_manager.discard_cards(indices, gui_main_game.gui_tool_card_container)

#region private

func _update_gold(gold:int, animated:bool) -> void:
	_gold = gold
	await gui_main_game.update_gold(_gold, animated)

func _end_day() -> void:
	field_container.handle_turn_end()
	if week_manager.get_day() == 6:
		for field:Field in field_container.fields:
			field.remove_plant()
		# if _gold >= week_manager.get_tax_due():
		gui_main_game.animate_show_week_summary(_gold, week_manager.get_tax_due())
		# gui_main_game.animate_show_shop(3, 2, _gold)
		# else:
			# print("lose")
	else:
		start_day()

func _on_week_summary_continue_button_pressed(gold_left:int) -> void:
	await _update_gold(_gold - week_manager.get_tax_due(), true)
	assert(_gold == gold_left)
	gui_main_game.animate_show_shop(3, 2, gold_left)
	
func _discard_all_tools() -> void:
	var discarding_indices:Array[int] = []
	for i in tool_manager.tool_deck.hand.size():
		discarding_indices.append(i)
	await tool_manager.discard_cards(discarding_indices, gui_main_game.gui_tool_card_container)

func _clear_tool_selection() -> void:
	tool_manager.select_tool(-1)
	gui_main_game.clear_tool_selection()
	field_container.clear_tool_indicators()

func _plant_new_seeds() -> void:
	var field_indices:Array[int] = field_container.get_all_field_indices()
	assert(field_indices.size() == field_container.fields.size())
	await Util.create_scaled_timer(0.2).timeout # If planting is needed, there would be a gold update animation, wait for that animationg to end before drawing new plants
	await plant_seed_manager.draw_cards(field_indices.size(), gui_main_game.gui_plant_seed_animation_container, field_indices, field_container)

#endregion

#region harvest flow

func _harvest() -> void:
	_harvesting_fields = field_container.get_harvestable_fields()
	if _harvesting_fields.is_empty():
		return
	_gold_gaining_fields = _harvesting_fields.duplicate()
	field_container.harvest_all_fields()
	await _all_field_gold_gained
	await plant_seed_manager.discard_cards(_harvesting_fields, gui_main_game.gui_plant_seed_animation_container, field_container)
	await plant_seed_manager.draw_cards(_harvesting_fields.size(), gui_main_game.gui_plant_seed_animation_container, _harvesting_fields, field_container)
	_harvesting_fields.clear()
	_gold_gaining_fields.clear()

#endregion

#region events
#region tool events

func _on_tool_selected(index:int) -> void:
	field_container.clear_tool_indicators()
	tool_manager.select_tool(index)
	var tool_data:ToolData = tool_manager.selected_tool
	if !tool_data:
		return
	if !tool_data.need_select_field:
		await tool_manager.apply_tool(self, [])
	
func _on_tool_application_started(index:int) -> void:
	var tool_data:ToolData = tool_manager.get_tool(index)
	tool_manager.discard_cards([index], gui_main_game.gui_tool_card_container)
	_clear_tool_selection()
	gui_main_game.toggle_all_ui(false)
	energy_tracker.spend(tool_data.energy_cost)

func _on_tool_application_completed(_index:int) -> void:
	await _harvest()
	gui_main_game.toggle_all_ui(true)

#region gui main events
func _on_end_turn_button_pressed() -> void:
	gui_main_game.toggle_all_ui(false)
	await weather_manager.apply_weather_actions(field_container.fields, gui_main_game.gui_weather_container.get_today_weather_icon())
	await field_container.trigger_end_day_ability(self)
	await _harvest()
	await _discard_all_tools()
	_end_day()
	
#region field events
func _on_field_harvest_started() -> void:
	gui_main_game.toggle_all_ui(false)

func _on_field_harvest_gold_update_requested(gold:int, index:int) -> void:
	await _update_gold(_gold + gold, true)
	_gold_gaining_fields.erase(index)
	if _gold_gaining_fields.is_empty():
		_all_field_gold_gained.emit()

func _on_field_hovered(hovered:bool, index:int) -> void:
	if tool_manager.selected_tool:
		if hovered && tool_manager.selected_tool.need_select_field:
			field_container.toggle_field_selection_indicator(true, tool_manager.selected_tool, index)
		else:
			field_container.toggle_field_selection_indicator(false, tool_manager.selected_tool, index)

func _on_field_pressed(index:int) -> void:
	if !tool_manager.selected_tool:
		return
	if tool_manager.selected_tool.is_all_fields:
		await tool_manager.apply_tool(self, field_container.fields)
	else:
		var field := field_container.fields[index]
		await tool_manager.apply_tool(self, [field])

#region weather events
func _on_weathers_updated() -> void:
	gui_main_game.update_weathers(weather_manager)

#region shop events
func _on_shop_next_week_pressed() -> void:
	start_new_week()

func _on_plant_shop_button_pressed(plant_data:PlantData) -> void:
	_update_gold(_gold - plant_data.cost, true)
	plant_seed_manager.add_plant(plant_data)

func _on_tool_shop_button_pressed(tool_data:ToolData) -> void:
	_update_gold(_gold - tool_data.cost, true)
	tool_manager.add_tool(tool_data)

#endregion

#region setter/getter

func _set_gold(val:int) -> void:
	_gold = val
	gui_main_game.gui_shop_main.update_for_gold(_gold)

#endregion
