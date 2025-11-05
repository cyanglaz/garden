class_name CombatMain
extends Node2D

signal reward_finished(tool_data:ToolData, from_global_position:Vector2)
signal level_started()
signal turn_started()

var hand_size := 5
const WIN_PAUSE_TIME := 0.5
const INSTANT_CARD_USE_DELAY := 0.3
const TOOL_APPLICATION_ERROR_HIDE_DELAY := 3.0

@onready var field_container: FieldContainer = %FieldContainer
@onready var gui: GUICombatMain = %GUI

var energy_tracker:ResourcePoint = ResourcePoint.new()
var weather_manager:WeatherManager = WeatherManager.new()
var contract_generator:ContractGenerator = ContractGenerator.new()
var power_manager:PowerManager = PowerManager.new()
var tool_manager:ToolManager
var plant_seed_manager:PlantSeedManager
var day_manager:DayManager = DayManager.new()
var session_summary:SessionSummary
var combat_modifier_manager:CombatModifierManager = CombatModifierManager.new()
var boost := 1: set = _set_boost
var _number_of_plants:int = 0
var _contract:ContractData
var _tool_application_error_timers:Dictionary = {}

var is_finished:bool = false

# From main_game:
var max_energy := 3
var chapter_manager:ChapterManager = ChapterManager.new()

func start(field_count:int, card_pool:Array[ToolData], energy_cap:int, contract:ContractData) -> void:

	session_summary = SessionSummary.new(contract)

	field_container.update_with_number_of_fields(field_count)
	field_container.field_hovered.connect(_on_field_hovered)
	field_container.field_pressed.connect(_on_field_pressed)
	field_container.field_harvest_started.connect(_on_field_harvest_started)
	field_container.field_harvest_completed.connect(_on_field_harvest_completed)
	field_container.field_action_application_completed.connect(_on_field_action_application_completed)
	field_container.mouse_field_updated.connect(_on_mouse_field_updated)

	weather_manager.weathers_updated.connect(_on_weathers_updated)

	tool_manager = ToolManager.new(card_pool.duplicate(), gui.gui_tool_card_container)
	tool_manager.tool_application_started.connect(_on_tool_application_started)
	tool_manager.tool_application_completed.connect(_on_tool_application_completed)
	tool_manager.tool_application_error.connect(_on_tool_application_error)
	tool_manager.hand_updated.connect(_on_hand_updated)

	gui.bind_power_manager(power_manager)
	gui.bind_energy(energy_tracker)
	gui.bind_tool_deck(tool_manager.tool_deck)
	gui.setup_plant_seed_animation_container(field_container)
	gui.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui.tool_selected.connect(_on_tool_selected)
	gui.plant_seed_drawn_animation_completed.connect(_on_plant_seed_drawn_animation_completed)
	gui.card_use_button_pressed.connect(_on_card_use_button_pressed)
	gui.mouse_exited_card.connect(_on_mouse_exited_card)
	gui.reward_finished.connect(_on_reward_finished)

	combat_modifier_manager.setup(self)

	max_energy = energy_cap
	energy_tracker.capped = false

	_contract = contract
	_start_new_level()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("de-select"):
		if tool_manager.selected_tool && !tool_manager.is_applying_tool:
			_clear_tool_selection()

#endregion

#region cards
func draw_cards(count:int) -> void:
	var draw_results:Array = await tool_manager.draw_cards(count)
	await power_manager.handle_card_added_to_hand_hook(draw_results)

func discard_cards(tools:Array) -> void:
	await tool_manager.discard_cards(tools)

func add_tools_to_hand(tool_datas:Array[ToolData], from_global_position:Vector2, pause:bool) -> void:
	await power_manager.handle_card_added_to_hand_hook(tool_datas)
	await tool_manager.add_tools_to_hand(tool_datas, from_global_position, pause)

func add_card_to_deck(tool_data:ToolData) -> void:
	tool_manager.add_tool_to_deck(tool_data)

#endregion

#powers
func update_power(power_id:String, stack:int) -> void:
	power_manager.update_power(power_id, stack)
	await power_manager.handle_activation_hook(self)
#region private
  
func _start_new_level() -> void:
	combat_modifier_manager.apply_modifiers(CombatModifier.ModifierTiming.LEVEL)
	boost = 1
	plant_seed_manager = PlantSeedManager.new(_contract.plants)
	_number_of_plants = plant_seed_manager.plant_datas.size()
	day_manager.start_new()
	gui.update_with_plants(plant_seed_manager.plant_datas)
	gui.update_with_contract(_contract, self)
	level_started.emit()
	_start_day()

func _start_day() -> void:
	combat_modifier_manager.apply_modifiers(CombatModifier.ModifierTiming.TURN)
	boost = maxi(boost - 1, 1)
	weather_manager.generate_next_weathers(chapter_manager.current_chapter)
	gui.toggle_all_ui(false)
	energy_tracker.setup(max_energy, max_energy)
	day_manager.next_day()
	gui.clear_tool_selection()
	gui.update_penalty_rate(_contract.get_penalty_rate(day_manager.day))
	if day_manager.day == 0:
		await gui.apply_boss_actions(GUIBoss.HookType.LEVEL_START)
		await Util.create_scaled_timer(0.2).timeout
		await _plant_new_seeds(2)
	await gui.apply_boss_actions(GUIBoss.HookType.TURN_START)
	await draw_cards(hand_size)
	gui.toggle_all_ui(true)
	turn_started.emit()

func _met_win_condition() -> bool:
	assert(_number_of_plants >= 0)
	return _number_of_plants == 0
	
func _win() -> void:
	if is_finished:
		return
	is_finished = true
	gui.permanently_lock_all_ui()
	await Util.create_scaled_timer(WIN_PAUSE_TIME).timeout
	await _discard_all_tools()
	session_summary.total_days += day_manager.day
	gui.animate_show_reward_main(_contract)

func _end_day() -> void:
	gui.toggle_all_ui(false)
	_clear_tool_selection()
	await _discard_all_tools()
	if _met_win_condition():
		return
	tool_manager.card_use_limit_reached = false
	await field_container.trigger_end_day_field_status_hooks(self)
	await field_container.trigger_end_day_plant_abilities(self)
	await weather_manager.apply_weather_actions(field_container.fields, self)
	await power_manager.handle_weather_application_hook(self, weather_manager.get_current_weather())
	weather_manager.pass_day()
	tool_manager.cleanup_for_turn()
	combat_modifier_manager.clear_for_turn()
	power_manager.remove_single_turn_powers()
	gui.toggle_all_ui(true)
	if _met_win_condition():
		# _win() is called by _harvest()
		return
	field_container.handle_turn_end()
	Events.request_rating_update.emit( -_contract.get_penalty_rate(day_manager.day))
	_start_day()
	
func _discard_all_tools() -> void:
	if tool_manager.tool_deck.hand.is_empty():
		return
	await tool_manager.discard_cards(tool_manager.tool_deck.hand.duplicate())

func _clear_tool_selection() -> void:
	tool_manager.select_tool(null)
	gui.clear_tool_selection()
	field_container.clear_tool_indicators()

func _plant_new_seeds(number_of_plants:int) -> void:
	var field_indices:Array[int] = field_container.get_next_empty_field_indices(number_of_plants)
	await plant_seed_manager.draw_plants(field_indices, gui.gui_plant_seed_animation_container)

func _handle_select_tool(tool_data:ToolData) -> void:
	field_container.clear_tool_indicators()
	tool_manager.select_tool(tool_data)

func _harvest(plant_index:int) -> void:
	var plant:Plant = field_container.get_plant(plant_index)
	if plant.can_harvest():
		plant.harvest(self)
	
func _handle_card_use(plant_index:int) -> void:
	tool_manager.apply_tool(self, field_container.plants, plant_index)
	await tool_manager.tool_application_completed

#endregion

#region gui

func _hide_custom_error(identifier:String) -> void:
	if _tool_application_error_timers.has(identifier):
		var timer:SceneTreeTimer = _tool_application_error_timers[identifier]
		timer.timeout.disconnect(_on_tool_application_error_timer_timeout)
		_tool_application_error_timers.erase(identifier)
	Events.request_hide_custom_error.emit(identifier)

#endregion

#region UI EVENTS
func _on_tool_selected(tool_data:ToolData) -> void:
	_handle_select_tool(tool_data)
	if tool_data.need_select_field:
		field_container.toggle_all_plants_selection_indicator(GUIFieldSelectionArrow.IndicatorState.READY)

func _on_mouse_exited_card(tool_data:ToolData) -> void:
	_hide_custom_error(tool_data.id)

func _on_card_use_button_pressed(tool_data:ToolData) -> void:
	assert(!tool_data.need_select_field)
	_handle_card_use(0)

func _on_end_turn_button_pressed() -> void:
	_end_day()

func _on_field_hovered(hovered:bool, index:int) -> void:
	_number_of_plants -= 1
	if tool_manager.selected_tool && tool_manager.selected_tool.need_select_field:
		if hovered:
			if tool_manager.selected_tool.all_fields:
				field_container.toggle_all_plants_selection_indicator(GUIFieldSelectionArrow.IndicatorState.CURRENT)
			else:
				field_container.toggle_plant_selection_indicator(GUIFieldSelectionArrow.IndicatorState.CURRENT, index)
		else:
			field_container.toggle_all_plants_selection_indicator(GUIFieldSelectionArrow.IndicatorState.READY)
	else:
		field_container.toggle_tooltip_for_plant(index, hovered)

func _on_field_pressed(index:int) -> void:
	if !tool_manager.selected_tool || !tool_manager.selected_tool.need_select_field:
		return
	_handle_card_use(index)

func _on_reward_finished(tool_data:ToolData, from_global_position:Vector2) -> void:
	if _contract.contract_type == ContractData.ContractType.BOSS:
		#beat demo
		pass # TODO: beat demo
	else:
		reward_finished.emit(tool_data, from_global_position)

#region other events

func _on_tool_application_started(tool_data:ToolData) -> void:
	gui.toggle_all_ui(false)
	if tool_data.get_final_energy_cost() > 0:
		energy_tracker.spend(tool_data.get_final_energy_cost())
	_clear_tool_selection()

func _on_tool_application_completed(tool_data:ToolData) -> void:
	if tool_manager.number_of_card_used_this_turn >= combat_modifier_manager.card_use_limit():
		tool_manager.card_use_limit_reached = true
	await power_manager.handle_tool_application_hook(self, tool_data)
	gui.toggle_all_ui(true)

func _on_tool_application_error(tool_data:ToolData, error_message:String) -> void:
	_clear_tool_selection()
	Events.request_show_custom_error.emit(error_message, tool_data.id)
	if _tool_application_error_timers.has(tool_data.id):
		var existing_timer:SceneTreeTimer = _tool_application_error_timers[tool_data.id]
		existing_timer.timeout.disconnect(_on_tool_application_error_timer_timeout)
	var timer:SceneTreeTimer = Util.create_scaled_timer(TOOL_APPLICATION_ERROR_HIDE_DELAY)
	_tool_application_error_timers[tool_data.id] = timer
	timer.timeout.connect(_on_tool_application_error_timer_timeout.bind(tool_data.id))

func _on_tool_application_error_timer_timeout(id:String) -> void:
	_hide_custom_error(id)

func _on_hand_updated(hand:Array) -> void:
	for tool_data in hand:
		tool_data.combat_main = self
		tool_data.request_refresh.emit()
	
func _on_field_action_application_completed(index:int) -> void:
	_harvest(index)

func _on_field_harvest_started() -> void:
	gui.toggle_all_ui(false)

func _on_field_harvest_completed(index:int, plant_data:PlantData) -> void:
	await plant_seed_manager.finish_plants([index], [plant_data], gui.gui_plant_seed_animation_container)
	if _met_win_condition():
		await _win()
	else:
		await plant_seed_manager.draw_plants([index], gui.gui_plant_seed_animation_container)
		energy_tracker.restore(boost)
		await draw_cards(boost)
		boost += 1
	gui.toggle_all_ui(true)

func _on_weathers_updated() -> void:
	gui.update_weathers(weather_manager)

func _on_plant_seed_drawn_animation_completed(plant_data:PlantData) -> void:
	await field_container.plant_seed(plant_data, self)

func _on_mouse_field_updated(field:Field) -> void:
	gui.update_mouse_field(field)

#endregion

#region setter/getter

func _set_boost(val:int) -> void:
	boost = val
	gui.update_boost(boost)

#endregion
