class_name MainGame
extends Node2D

signal _all_field_harvested()

var hand_size := 5
const DAYS_TO_WEEK := 7
const WIN_PAUSE_TIME := 0.4
const INSTANT_CARD_USE_DELAY := 0.3

@export var player:PlayerData
@export var test_tools:Array[ToolData]
@export var test_number_of_fields := 0
@export var level_data:LevelData

@onready var gui_main_game: GUIMainGame = %GUIGameSession
@onready var field_container: FieldContainer = %FieldContainer

var session_seed := 0

var energy_tracker:ResourcePoint = ResourcePoint.new()
var week_manager:WeekManager = WeekManager.new()
var weather_manager:WeatherManager = WeatherManager.new()
var tool_manager:ToolManager
var plant_seed_manager:PlantSeedManager
var max_energy := 3
var session_summary:SessionSummary
var _gold := 0: set = _set_gold

var _harvesting_fields:Array = []

func _ready() -> void:
	Singletons.main_game = self
	
	session_summary = SessionSummary.new()
	
	#field signals
	if test_number_of_fields > 0:
		field_container.update_with_number_of_fields(test_number_of_fields)
	else:
		field_container.update_with_number_of_fields(player.number_of_fields)
	field_container.field_hovered.connect(_on_field_hovered)
	field_container.field_pressed.connect(_on_field_pressed)
	field_container.field_harvest_started.connect(_on_field_harvest_started)
	field_container.field_harvest_completed.connect(_on_field_harvest_completed)
	
	#weather signals
	weather_manager.weathers_updated.connect(_on_weathers_updated)
	
	if !test_tools.is_empty():
		#test_tools.append_array(test_tools)
		#test_tools.append_array(test_tools)
		
		#tool signals
		tool_manager = ToolManager.new(test_tools)
	else:
		tool_manager = ToolManager.new(player.initial_tools)
		
	tool_manager.tool_application_started.connect(_on_tool_application_started)
	tool_manager.tool_application_completed.connect(_on_tool_application_completed)
		
	#gui main signals
	gui_main_game.update_player(player)
	gui_main_game.bind_energy(energy_tracker)
	gui_main_game.bind_tool_deck(tool_manager.tool_deck)
	gui_main_game.setup_plant_seed_animation_container(field_container)
	gui_main_game.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui_main_game.tool_selected.connect(_on_tool_selected)
	gui_main_game.week_summary_continue_button_pressed.connect(_on_week_summary_continue_button_pressed)
	gui_main_game.gold_increased.connect(_on_week_summary_gold_increased)
	gui_main_game.plant_seed_drawn_animation_completed.connect(_on_plant_seed_drawn_animation_completed)
	
	#shop signals
	gui_main_game.gui_shop_main.next_week_button_pressed.connect(_on_shop_next_week_pressed)
	gui_main_game.gui_shop_main.tool_shop_button_pressed.connect(_on_tool_shop_button_pressed)
	
	energy_tracker.can_be_capped = false
	start_new_week()
	_update_gold(_gold, false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("de-select"):
		if tool_manager.selected_tool:
			_clear_tool_selection()

func start_new_week() -> void:
	plant_seed_manager = PlantSeedManager.new(level_data.plants)
	gui_main_game.update_with_level_data(level_data)
	gui_main_game.update_with_plants(plant_seed_manager.plant_datas)
	tool_manager.refresh_deck()
	week_manager.next_week(level_data)
	session_summary.week = week_manager.week
	weather_manager.generate_weathers(level_data)
	gui_main_game.update_week(week_manager.week)
	start_day()

func start_day() -> void:
	gui_main_game.toggle_all_ui(false)
	energy_tracker.setup(max_energy, max_energy)
	week_manager.next_day()
	weather_manager.day = week_manager.get_day()
	gui_main_game.update_day_left(week_manager.get_day_left())
	gui_main_game.clear_tool_selection()
	await Util.await_for_tiny_time()
	if week_manager.get_day() == 0:
		await Util.create_scaled_timer(0.2).timeout
		await _plant_new_seeds()
	await draw_cards(hand_size)
	gui_main_game.toggle_all_ui(true)

func add_control_to_overlay(control:Control) -> void:
	gui_main_game.add_control_to_overlay(control)

func draw_cards(count:int) -> void:
	var draw_results:Array = await tool_manager.draw_cards(count, gui_main_game.gui_tool_card_container)
	for tool_data:ToolData in draw_results:
		if tool_data.specials.has(ToolData.Special.USE_ON_DRAW):
			var index:int = tool_manager.tool_deck.hand.find(tool_data)
			_handle_select_tool(index)
			await _apply_instant_tool()

func discard_cards(tools:Array) -> void:
	await tool_manager.discard_cards(tools, gui_main_game.gui_tool_card_container)

#region private

func _update_gold(gold:int, animated:bool) -> void:
	_gold = gold
	await gui_main_game.update_gold(_gold, animated)

func _met_win_condition() -> bool:
	return !field_container.has_plants() && !plant_seed_manager.has_more_plants()
	
func _win() -> void:
	gui_main_game.toggle_all_ui(false)
	await Util.create_scaled_timer(WIN_PAUSE_TIME).timeout
	for field:Field in field_container.fields:
		field.remove_plant()
	await _discard_all_tools()
	_harvesting_fields.clear()
	session_summary.total_days_skipped += week_manager.get_day_left()
	gui_main_game.animate_show_week_summary(week_manager.get_day_left())
	gui_main_game.toggle_all_ui(true)

func _lose() -> void:
	gui_main_game.toggle_all_ui(false)
	await Util.create_scaled_timer(WIN_PAUSE_TIME).timeout
	gui_main_game.animate_show_game_over(session_summary)
	gui_main_game.toggle_all_ui(true)

func _end_day() -> void:
	gui_main_game.toggle_all_ui(false)
	await _discard_all_tools()
	await weather_manager.apply_weather_actions(field_container.fields, gui_main_game.gui_weather_container.get_today_weather_icon())
	await field_container.trigger_end_day_hook(self)
	await field_container.trigger_end_day_ability(self)
	var won := await _harvest()
	if won:
		return #Harvest won the game, no need to discard tools or end the day
	gui_main_game.toggle_all_ui(true)
	field_container.handle_turn_end()
	if week_manager.day_manager.get_day_left() == 0:
		if _met_win_condition():	
			return #Win condition has been met at the end of the day, _harvest will take care of win
		else:
			_lose()
	else:
		start_day()

func _on_week_summary_continue_button_pressed() -> void:
	if week_manager.is_boss_week():
		gui_main_game.animate_show_demo_end()
	else:
		gui_main_game.animate_show_shop(3, _gold)
	
func _discard_all_tools() -> void:
	if tool_manager.tool_deck.hand.is_empty():
		return
	await tool_manager.discard_cards(tool_manager.tool_deck.hand.duplicate(), gui_main_game.gui_tool_card_container)

func _clear_tool_selection() -> void:
	tool_manager.select_tool(-1)
	gui_main_game.clear_tool_selection()
	field_container.clear_tool_indicators()

func _plant_new_seeds() -> void:
	var field_indices:Array[int] = field_container.get_all_field_indices()
	assert(field_indices.size() == field_container.fields.size())
	await Util.create_scaled_timer(0.2).timeout # If planting is needed, there would be a p update animation, wait for that animation to end before drawing new plants
	await plant_seed_manager.draw_plants(field_indices, gui_main_game.gui_plant_seed_animation_container,)

func _handle_select_tool(index:int) -> void:
	field_container.clear_tool_indicators()
	tool_manager.select_tool(index)

func _apply_instant_tool() -> void:
	await Util.create_scaled_timer(INSTANT_CARD_USE_DELAY).timeout
	await tool_manager.apply_tool(self, field_container.fields, 0, gui_main_game.gui_tool_card_container)

#endregion

#region harvest flow

func _harvest() -> bool:
	var field_indices_to_harvest = field_container.get_harvestable_fields()
	_harvesting_fields = field_indices_to_harvest.duplicate()
	var harvestable_plant_datas:Array = field_container.get_plants(_harvesting_fields).map(func(plant:Plant): return plant.data)
	if _harvesting_fields.is_empty():
		return false
	field_container.harvest_all_fields()
	await _all_field_harvested
	await plant_seed_manager.finish_plants(field_indices_to_harvest, harvestable_plant_datas, gui_main_game.gui_plant_seed_animation_container)
	if _met_win_condition():
		await _win()
		return true
	else:
		await plant_seed_manager.draw_plants(field_indices_to_harvest, gui_main_game.gui_plant_seed_animation_container)
		return false
	
func _remove_plants(field_indices:Array[int]) -> void:
	for field_index:int in field_indices:
		var field:Field = field_container.fields[field_index]
		field.remove_plant()

#endregion

#region events
#region tool events

func _on_tool_selected(index:int) -> void:
	_handle_select_tool(index)
	var tool_data:ToolData = tool_manager.selected_tool
	if !tool_data:
		return
	if !tool_data.need_select_field:
		await _apply_instant_tool()

func _on_tool_application_started(tool_data:ToolData) -> void:
	_clear_tool_selection()
	gui_main_game.toggle_all_ui(false)
	energy_tracker.spend(tool_data.energy_cost)

func _on_tool_application_completed() -> void:
	await _harvest()
	gui_main_game.toggle_all_ui(true)

#region gui main events
func _on_end_turn_button_pressed() -> void:
	_end_day()
	
#region field events
func _on_field_harvest_started() -> void:
	pass
	#gui_main_game.toggle_all_ui(false)

func _on_field_harvest_completed(index:int) -> void:
	var field:Field = field_container.fields[index]
	field.remove_plant()
	_harvesting_fields.erase(index)
	if _harvesting_fields.is_empty():
		_all_field_harvested.emit()

func _on_field_hovered(hovered:bool, index:int) -> void:
	if tool_manager.selected_tool:
		if hovered && tool_manager.selected_tool.need_select_field:
			field_container.toggle_field_selection_indicator(true, tool_manager.selected_tool, index)
		else:
			field_container.toggle_field_selection_indicator(false, tool_manager.selected_tool, index)

func _on_field_pressed(index:int) -> void:
	if !tool_manager.selected_tool:
		return
	await tool_manager.apply_tool(self, field_container.fields, index, gui_main_game.gui_tool_card_container)

func _on_plant_seed_drawn_animation_completed(field_index:int, plant_data:PlantData) -> void:
	field_container.fields[field_index].plant_seed(plant_data)

#region weather events
func _on_weathers_updated() -> void:
	gui_main_game.update_weathers(weather_manager)

#region shop events
func _on_shop_next_week_pressed() -> void:
	start_new_week()

func _on_tool_shop_button_pressed(tool_data:ToolData) -> void:
	_update_gold(_gold - tool_data.cost, true)
	tool_manager.add_tool_to_deck(tool_data)

#region week summary events
func _on_week_summary_gold_increased(gold:int) -> void:
	_update_gold(_gold + gold, true)
	session_summary.total_gold_earned += gold
#endregion

#endregion

#region setter/getter

func _set_gold(val:int) -> void:
	_gold = val
	gui_main_game.gui_shop_main.update_for_gold(_gold)

#endregion
