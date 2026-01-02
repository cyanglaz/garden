class_name CombatMain
extends Node2D

signal reward_finished(tool_data:ToolData, from_global_position:Vector2)
signal level_started()
signal turn_started()
signal beat_final_boss()

var hand_size := 5
const WIN_PAUSE_TIME := 0.5
const INSTANT_CARD_USE_DELAY := 0.3
const TOOL_APPLICATION_ERROR_HIDE_DELAY := 3.0
const BACKGROUND_MUSIC_FADE_IN_TIME := 1.0

@export var test_weather:WeatherData

@onready var weather_main: WeatherMain = %WeatherMain
@onready var plant_field_container: PlantFieldContainer = %PlantFieldContainer
@onready var player: Node2D = %Player
@onready var gui: GUICombatMain = %GUI
@onready var background_music_player: AudioStreamPlayer2D = %BackgroundMusicPlayer

var energy_tracker:ResourcePoint = ResourcePoint.new()
var combat_generator:CombatGenerator = CombatGenerator.new()
var power_manager:PowerManager = PowerManager.new()
var tool_manager:ToolManager
var day_manager:DayManager = DayManager.new()
var session_summary:SessionSummary
var combat_modifier_manager:CombatModifierManager = CombatModifierManager.new()
var boost := 1: set = _set_boost
var _combat:CombatData
var _tool_application_error_timers:Dictionary = {}
var _current_player_index:int = 0: set = _set_current_player_index

var is_finished:bool = false

# From main_game:
var max_energy := 3
var _chapter:int = 0

func _ready() -> void:
	Events.request_add_tools_to_hand.connect(_on_request_add_tools_to_hand)
	Events.request_add_tools_to_discard_pile.connect(_on_request_add_tools_to_discard_pile)
	Events.request_modify_hand_cards.connect(_on_request_modify_hand_cards)

func start(card_pool:Array[ToolData], energy_cap:int, combat:CombatData, chapter:int) -> void:

	session_summary = SessionSummary.new(combat)

	plant_field_container.field_hovered.connect(_on_field_hovered)
	plant_field_container.field_pressed.connect(_on_field_pressed)
	plant_field_container.plant_bloom_started.connect(_on_plant_bloom_started)
	plant_field_container.plant_bloom_completed.connect(_on_plant_bloom_completed)
	plant_field_container.plant_action_application_completed.connect(_on_plant_action_application_completed)
	plant_field_container.mouse_plant_updated.connect(_on_mouse_plant_updated)

	weather_main.weathers_updated.connect(_on_weathers_updated)
	weather_main.test_weather = test_weather

	tool_manager = ToolManager.new(card_pool.duplicate(), gui.gui_tool_card_container)
	tool_manager.tool_application_started.connect(_on_tool_application_started)
	tool_manager.tool_application_completed.connect(_on_tool_application_completed)
	tool_manager.tool_application_error.connect(_on_tool_application_error)
	tool_manager.hand_updated.connect(_on_hand_updated)

	gui.bind_power_manager(power_manager)
	gui.bind_energy(energy_tracker)
	gui.bind_tool_deck(tool_manager.tool_deck)
	gui.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui.tool_selected.connect(_on_tool_selected)
	gui.card_use_button_pressed.connect(_on_card_use_button_pressed)
	gui.mouse_exited_card.connect(_on_mouse_exited_card)
	gui.reward_finished.connect(_on_reward_finished)

	combat_modifier_manager.setup(self)

	max_energy = energy_cap
	energy_tracker.capped = false

	background_music_player.volume_db = -80

	_combat = combat
	_chapter = chapter
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

func add_tools_to_hand(tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
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
	plant_field_container.setup_with_plants(_combat.plants)
	day_manager.start_new()
	gui.update_with_combat(_combat, self)
	level_started.emit()
	_set_current_player_index(0)
	await weather_main.start(_chapter)
	_start_turn()

func _start_turn() -> void:
	combat_modifier_manager.apply_modifiers(CombatModifier.ModifierTiming.TURN)
	boost = maxi(boost - 1, 1)
	gui.toggle_all_ui(false)
	energy_tracker.setup(max_energy, max_energy)
	day_manager.next_day()
	gui.clear_tool_selection()
	if day_manager.day == 0:
		_fade_music(true)
		await gui.apply_boss_actions(GUIBoss.HookType.LEVEL_START)
	await gui.apply_boss_actions(GUIBoss.HookType.TURN_START)
	await draw_cards(hand_size)
	await plant_field_container.trigger_start_turn_hooks(self)
	gui.toggle_all_ui(true)
	turn_started.emit()
	#_win()

func _end_turn() -> void:
	gui.toggle_all_ui(false)
	_clear_tool_selection()
	await plant_field_container.trigger_end_turn_hooks(self)
	await weather_main.apply_weather_actions(plant_field_container.plants, self)
	await power_manager.handle_weather_application_hook(self, weather_main.get_current_weather())
	tool_manager.card_use_limit_reached = false
	await weather_main.night_fall()
	await _trigger_turn_end_cards()
	await _discard_all_tools()
	if _met_win_condition():
		return
	tool_manager.cleanup_for_turn()
	combat_modifier_manager.clear_for_turn()
	power_manager.remove_single_turn_powers()
	if _met_win_condition():
		# _win() is called by _bloom()
		return
	plant_field_container.handle_turn_end()
	await weather_main.pass_day()
	gui.toggle_all_ui(true)
	_start_turn()

func _met_win_condition() -> bool:
	return plant_field_container.are_all_plants_bloom()
	
func _win() -> void:
	if is_finished:
		return
	is_finished = true
	gui.permanently_lock_all_ui()
	_fade_music(false)
	await Util.create_scaled_timer(WIN_PAUSE_TIME).timeout
	if _chapter == MainGame.NUMBER_OF_CHAPTERS - 1 && _combat.combat_type == CombatData.CombatType.BOSS:
		beat_final_boss.emit()
		return
	await _discard_all_tools()
	weather_main.level_end_stop()
	session_summary.total_days += day_manager.day
	gui.animate_show_reward_main(_combat) 
	
func _trigger_turn_end_cards() -> void:
	if tool_manager.tool_deck.hand.is_empty():
		return
	await tool_manager.trigger_turn_end_cards(self, plant_field_container.plants)

func _discard_all_tools() -> void:
	if tool_manager.tool_deck.hand.is_empty():
		return
	await tool_manager.discard_cards(tool_manager.tool_deck.hand.duplicate())

func _clear_tool_selection() -> void:
	tool_manager.select_tool(null)
	gui.clear_tool_selection()
	plant_field_container.clear_tool_indicators()

func _handle_select_tool(tool_data:ToolData) -> void:
	plant_field_container.clear_tool_indicators()
	tool_manager.select_tool(tool_data)

func _bloom(plant_index:int) -> void:
	var field:Field = plant_field_container.get_field(plant_index)
	if field.can_bloom():
		field.bloom()
	
func _handle_card_use(plant_index:int) -> void:
	tool_manager.apply_tool(self, plant_field_container.plants, plant_index)
	await tool_manager.tool_application_completed

func _fade_music(fade_in:bool) -> void:
	if fade_in:
		background_music_player.play()
	var target_volume_db:float = 0 if fade_in else -80
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(background_music_player, "volume_db", target_volume_db, BACKGROUND_MUSIC_FADE_IN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	if !fade_in:
		background_music_player.stop()
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
	if tool_data.all_fields:
		plant_field_container.toggle_all_plants_selection_indicator(GUIFieldSelectionArrow.IndicatorState.CURRENT)
	elif tool_data.need_select_field:
		plant_field_container.toggle_all_plants_selection_indicator(GUIFieldSelectionArrow.IndicatorState.READY)

func _on_mouse_exited_card(tool_data:ToolData) -> void:
	_hide_custom_error(tool_data.id)

func _on_card_use_button_pressed(tool_data:ToolData) -> void:
	assert(!tool_data.need_select_field)
	_handle_card_use(0)

func _on_end_turn_button_pressed() -> void:
	_end_turn()

func _on_field_hovered(hovered:bool, index:int) -> void:
	if tool_manager.selected_tool && tool_manager.selected_tool.need_select_field:
		if hovered:
			plant_field_container.toggle_plant_selection_indicator(GUIFieldSelectionArrow.IndicatorState.CURRENT, index)
		else:
			plant_field_container.toggle_all_plants_selection_indicator(GUIFieldSelectionArrow.IndicatorState.READY)
	else:
		plant_field_container.toggle_tooltip_for_plant(index, hovered)

func _on_field_pressed(index:int) -> void:
	if !tool_manager.selected_tool || !tool_manager.selected_tool.has_field_action:
		return
	_handle_card_use(index)

func _on_reward_finished(tool_data:ToolData, from_global_position:Vector2) -> void:
	if _combat.combat_type == CombatData.CombatType.BOSS:
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
	
func _on_plant_action_application_completed(index:int) -> void:
	_bloom(index)

func _on_plant_bloom_started() -> void:
	gui.toggle_all_ui(false)

func _on_plant_bloom_completed() -> void:
	if _met_win_condition():
		await _win()
	else:
		await draw_cards(boost)
		boost += 1
	gui.toggle_all_ui(true)

func _on_weathers_updated() -> void:
	gui.update_weathers(weather_main.weather_manager)

func _on_mouse_plant_updated(plant:Plant) -> void:
	gui.update_mouse_plant(plant)

func _on_request_add_tools_to_hand(tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
	gui.toggle_all_ui(false)
	await add_tools_to_hand(tool_datas, from_global_position, pause)
	gui.toggle_all_ui(true)

func _on_request_add_tools_to_discard_pile(tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
	gui.toggle_all_ui(false)
	await tool_manager.add_tools_to_discard_pile(tool_datas, from_global_position, pause)
	gui.toggle_all_ui(true)

func _on_request_modify_hand_cards(callable:Callable) -> void:
	gui.toggle_all_ui(false)
	await callable.call(tool_manager.tool_deck.hand)
	tool_manager.refresh_ui()
	gui.toggle_all_ui(true)

#endregion

#region setter/getter

func _set_boost(val:int) -> void:
	boost = val
	gui.update_boost(boost)

func _set_current_player_index(value:int) -> void:
	_current_player_index = value
	player.move_to_x(plant_field_container.get_field(value).global_position.x)

#endregion
