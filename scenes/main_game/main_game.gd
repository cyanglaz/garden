class_name MainGame
extends Node2D

signal _all_field_harvested()

var hand_size := 5
const DAYS_TO_WEEK := 7
const WIN_PAUSE_TIME := 0.4
const INSTANT_CARD_USE_DELAY := 0.3
const DETAIL_TOOLTIP_DELAY := 0.8
const INITIAL_RATING_VALUE := 100
const INITIAL_RATING_MAX_VALUE := 100
const CONTRACT_COUNT := 2
const NEW_CONTRACT_PAUSE_TIME := 0.3

@export var player:PlayerData
@export var test_tools:Array[ToolData]
@export var test_number_of_fields := 0
@export var test_contract:ContractData

@onready var gui_main_game: GUIMainGame = %GUIGameSession
@onready var field_container: FieldContainer = %FieldContainer
@onready var feedback_camera_2d: FeedbackCamera2D = %FeedbackCamera2D

var session_seed := 0

var energy_tracker:ResourcePoint = ResourcePoint.new()
var weather_manager:WeatherManager = WeatherManager.new()
var chapter_manager:ChapterManager = ChapterManager.new()
var contract_generator:ContractGenerator = ContractGenerator.new()
var power_manager:PowerManager = PowerManager.new()
var tool_manager:ToolManager
var plant_seed_manager:PlantSeedManager
var day_manager:DayManager = DayManager.new()
var max_energy := 3
var session_summary:SessionSummary
var hovered_data:ThingData: set = _set_hovered_data
var rating:ResourcePoint = ResourcePoint.new()
var _gold := 0: set = _set_gold
var _selected_contract:ContractData
var _level:int = 0

var _harvesting_fields:Array = []

func _ready() -> void:
	Singletons.main_game = self
	PopupThing.clear_popup_things()
	
	session_summary = SessionSummary.new()
	rating.setup(INITIAL_RATING_VALUE, INITIAL_RATING_MAX_VALUE)
	
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
		tool_manager = ToolManager.new(test_tools, gui_main_game.gui_tool_card_container)
	else:
		tool_manager = ToolManager.new(player.initial_tools, gui_main_game.gui_tool_card_container)
		
	tool_manager.tool_application_started.connect(_on_tool_application_started)
	tool_manager.tool_application_completed.connect(_on_tool_application_completed)

	#gui main signals
	gui_main_game.update_player(player)
	gui_main_game.bind_power_manager(power_manager)
	gui_main_game.bind_energy(energy_tracker)
	gui_main_game.bind_tool_deck(tool_manager.tool_deck)
	gui_main_game.setup_plant_seed_animation_container(field_container)
	gui_main_game.bind_with_rating(rating)
	gui_main_game.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui_main_game.tool_selected.connect(_on_tool_selected)
	gui_main_game.plant_seed_drawn_animation_completed.connect(_on_plant_seed_drawn_animation_completed)
	gui_main_game.contract_selected.connect(_on_contract_selected)
	gui_main_game.reward_finished.connect(_on_reward_finished)
	
	#shop signals
	gui_main_game.gui_shop_main.next_level_button_pressed.connect(_on_shop_next_level_pressed)
	gui_main_game.gui_shop_main.tool_shop_button_pressed.connect(_on_tool_shop_button_pressed)
	
	energy_tracker.capped = false
	contract_generator.generate_bosses(1)
	_start_new_chapter()
	update_gold(0, false)
	
	#gui_main_game.animate_show_shop(3, 0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("de-select"):
		if tool_manager.selected_tool:
			_clear_tool_selection()
	elif event.is_action_pressed("view_detail"):
		if hovered_data:
			show_thing_info_view(hovered_data)
			hovered_data = null

#endregion

#region cards
func draw_cards(count:int) -> void:
	var draw_results:Array = await tool_manager.draw_cards(count)
	await power_manager.handle_card_added_to_hand_hook(draw_results)
	await tool_manager.apply_auto_tools(self, field_container.fields, func(tool_data:ToolData): return tool_data.specials.has(ToolData.Special.USE_ON_DRAW))

func discard_cards(tools:Array) -> void:
	await tool_manager.discard_cards(tools)

func add_temp_tools_to_hand(tool_datas:Array[ToolData], from_global_position:Vector2, pause:bool) -> void:
	await power_manager.handle_card_added_to_hand_hook(tool_datas)
	await tool_manager.add_temp_tools_to_hand(tool_datas, from_global_position, pause)

func add_card_to_deck(tool_data:ToolData) -> void:
	tool_manager.add_tool_to_deck(tool_data)

#endregion

#powers
func update_power(power_id:String, stack:int) -> void:
	power_manager.update_power(power_id, stack)
	await power_manager.handle_activation_hook(self)

#endregion

#region rating

func update_rating(val:int) -> void:
	rating.value += val
	await gui_main_game.rating_update_finished
	if rating.value == 0:
		_lose()

#endregion

#region gold

func update_gold(gold_diff:int, animated:bool) -> void:
	_gold += gold_diff
	if gold_diff > 0:
		session_summary.total_gold_earned += gold_diff
	await gui_main_game.update_gold(gold_diff, animated)

#endregion

#region gui

func add_control_to_overlay(control:Control) -> void:
	gui_main_game.add_control_to_overlay(control)

func clear_all_tooltips() -> void:
	gui_main_game.clear_all_tooltips()

func show_thing_info_view(data:Resource) -> void:
	gui_main_game.gui_thing_info_view.show_with_data(data)

func show_dialogue(type:GUIDialogueItem.DialogueType) -> void:
	gui_main_game.show_dialogue(type)
	
func hide_dialogue(type:GUIDialogueItem.DialogueType) -> void:
	gui_main_game.hide_dialogue(type)

#endregion

#region private

func _start_new_chapter() -> void:
	_level = 3
	chapter_manager.next_chapter()
	weather_manager.generate_next_weathers(chapter_manager.current_chapter)
	contract_generator.generate_contracts(chapter_manager.current_chapter)
	gui_main_game.show_boss_icon(contract_generator.boss_contracts[0].boss_data)
	#_selected_contract = contract_generator.pick_contracts(CONTRACT_COUNT, _level)[0]
	#gui_main_game.animate_show_reward_main(_selected_contract)
	_select_contract()

func _select_contract() -> void:
	gui_main_game.hide_current_contract()
	var picked_contracts := contract_generator.pick_contracts(CONTRACT_COUNT, _level)
	gui_main_game.animate_show_contract_selection(picked_contracts)
  
func _start_new_level() -> void:
	gui_main_game.show_current_contract(_selected_contract)
	power_manager.clear_powers()
	if test_contract:
		_selected_contract = test_contract
	plant_seed_manager = PlantSeedManager.new(_selected_contract.plants)
	tool_manager.refresh_deck()
	session_summary.contract = _selected_contract
	day_manager.start_new(_selected_contract)
	gui_main_game.update_with_plants(plant_seed_manager.plant_datas)

	_start_day()

func _start_day() -> void:
	weather_manager.generate_next_weathers(chapter_manager.current_chapter)
	gui_main_game.toggle_all_ui(false)
	energy_tracker.setup(max_energy, max_energy)
	day_manager.next_day()
	gui_main_game.update_day_left(day_manager.get_grace_period_day_left(), _selected_contract.penalty_rate)
	gui_main_game.clear_tool_selection()
	await Util.await_for_tiny_time()
	if day_manager.day == 0:
		await _selected_contract.apply_boss_actions(self, BossScript.HookType.LEVEL_START)
		await Util.create_scaled_timer(0.2).timeout
		await _plant_new_seeds()
	await _selected_contract.apply_boss_actions(self, BossScript.HookType.TURN_START)
	await draw_cards(hand_size)
	gui_main_game.toggle_all_ui(true)

func _met_win_condition() -> bool:
	return !field_container.has_plants() && !plant_seed_manager.has_more_plants()
	
func _win() -> void:
	gui_main_game.toggle_all_ui(false)
	tool_manager.cleanup_deck()
	await Util.create_scaled_timer(WIN_PAUSE_TIME).timeout
	for field:Field in field_container.fields:
		field.remove_plant()
	await _discard_all_tools()
	field_container.clear_all_statuses()
	_harvesting_fields.clear()
	session_summary.total_days_skipped += day_manager.get_grace_period_day_left()
	gui_main_game.animate_show_reward_main(_selected_contract)
	gui_main_game.toggle_all_ui(true)
	_level += 1

func _lose() -> void:
	gui_main_game.toggle_all_ui(false)
	await Util.create_scaled_timer(WIN_PAUSE_TIME).timeout
	gui_main_game.animate_show_game_over(session_summary)
	gui_main_game.toggle_all_ui(true)

func _end_day() -> void:
	gui_main_game.toggle_all_ui(false)
	_clear_tool_selection()
	await tool_manager.apply_auto_tools(self, field_container.fields, func(tool_data:ToolData): return tool_data.specials.has(ToolData.Special.WITHER))
	await _discard_all_tools()
	await field_container.trigger_end_day_hook(self)
	await field_container.trigger_end_day_ability(self)
	await weather_manager.apply_weather_actions(field_container.fields, gui_main_game.gui_weather_container.get_today_weather_icon())
	weather_manager.pass_day()
	var won := await _harvest()
	gui_main_game.toggle_all_ui(true)
	if won:
		return #Harvest won the game, no need to discard tools or end the day
	field_container.handle_turn_end()
	if day_manager.get_grace_period_day_left() <= 0:
		await update_rating( -_selected_contract.penalty_rate)
	_start_day()

func _on_reward_finished(tool_data:ToolData) -> void:
	if _selected_contract.contract_type == ContractData.ContractType.BOSS:
		gui_main_game.hide_boss_icon()
		gui_main_game.animate_show_demo_end()
	else:
		if tool_data:
			tool_manager.add_tool_to_deck(tool_data)
			await Util.create_scaled_timer(NEW_CONTRACT_PAUSE_TIME).timeout
		_select_contract()
	
func _discard_all_tools() -> void:
	if tool_manager.tool_deck.hand.is_empty():
		return
	await tool_manager.discard_cards(tool_manager.tool_deck.hand.duplicate())

func _clear_tool_selection() -> void:
	tool_manager.select_tool(null)
	gui_main_game.clear_tool_selection()
	field_container.clear_tool_indicators()

func _plant_new_seeds() -> void:
	var field_indices:Array[int] = field_container.get_all_field_indices()
	assert(field_indices.size() == field_container.fields.size())
	await Util.create_scaled_timer(0.2).timeout # If planting is needed, there would be a p update animation, wait for that animation to end before drawing new plants
	await plant_seed_manager.draw_plants(field_indices, gui_main_game.gui_plant_seed_animation_container,)

func _handle_select_tool(tool_data:ToolData) -> void:
	field_container.clear_tool_indicators()
	tool_manager.select_tool(tool_data)

func _apply_instant_tool() -> void:
	await Util.create_scaled_timer(INSTANT_CARD_USE_DELAY).timeout
	tool_manager.apply_tool(self, field_container.fields, 0)
	await tool_manager.tool_application_completed

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

func _on_tool_selected(tool_data:ToolData) -> void:
	_handle_select_tool(tool_data)
	if tool_data.need_select_field:
		field_container.ready_field_selection_indicators()
	if !tool_data:
		return
	if !tool_data.need_select_field:
		await _apply_instant_tool()

func _on_tool_application_started(tool_data:ToolData) -> void:
	_clear_tool_selection()
	gui_main_game.toggle_all_ui(false)
	if tool_data.energy_cost > 0:
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
	if tool_manager.selected_tool && tool_manager.selected_tool.need_select_field:
		if hovered:
			field_container.toggle_field_selection_indicator(GUIFieldSelectionArrow.IndicatorState.CURRENT, tool_manager.selected_tool, index)
		else:
			field_container.ready_field_selection_indicators()

func _on_field_pressed(index:int) -> void:
	if !tool_manager.selected_tool || !tool_manager.selected_tool.need_select_field:
		return
	tool_manager.apply_tool(self, field_container.fields, index)

func _on_plant_seed_drawn_animation_completed(field_index:int, plant_data:PlantData) -> void:
	field_container.fields[field_index].plant_seed(plant_data)

#region weather events
func _on_weathers_updated() -> void:
	gui_main_game.update_weathers(weather_manager)

#region shop events
func _on_shop_next_level_pressed() -> void:
	_select_contract()

func _on_tool_shop_button_pressed(tool_data:ToolData) -> void:
	update_gold(_gold - tool_data.cost, true)
	tool_manager.add_tool_to_deck(tool_data)

#region contract selection events
func _on_contract_selected(contract_data:ContractData) -> void:
	_selected_contract = contract_data
	_start_new_level()
#endregion

#endregion

#region setter/getter

func _set_gold(val:int) -> void:
	_gold = val
	gui_main_game.gui_shop_main.update_for_gold(_gold)

func _set_hovered_data(val:ThingData) -> void:
	hovered_data = val
	if hovered_data:
		await Util.create_scaled_timer(DETAIL_TOOLTIP_DELAY).timeout
		if hovered_data:
			show_dialogue(GUIDialogueItem.DialogueType.THING_DETAIL)
	else:
		hide_dialogue(GUIDialogueItem.DialogueType.THING_DETAIL)

#endregion
