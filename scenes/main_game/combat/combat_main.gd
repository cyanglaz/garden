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
const MAX_HAND_WARNING_HIDE_DELAY := 2.0
const BACKGROUND_MUSIC_FADE_IN_TIME := 1.0
const END_TURN_UNIQUE_ID := "end_turn"

@export var test_weather:WeatherData

@onready var weather_main: WeatherMain = %WeatherMain
@onready var plant_field_container: PlantFieldContainer = %PlantFieldContainer
@onready var player: Player = %Player
@onready var gui: GUICombatMain = %GUI
@onready var background_music_player: AudioStreamPlayer2D = %BackgroundMusicPlayer

var energy_tracker:ResourcePoint = ResourcePoint.new()
var combat_generator:CombatGenerator = CombatGenerator.new()
var tool_manager:ToolManager
var day_manager:DayManager = DayManager.new()
var session_summary:SessionSummary
var combat_modifier_manager:CombatModifierManager = CombatModifierManager.new()
var combat_queue_manager: CombatQueueManager = CombatQueueManager.new()
var boost := 1: set = _set_boost
var _combat:CombatData
var _tool_application_error_timers:Dictionary = {}
var _max_hand_warning_timer:SceneTreeTimer = null
var _owned_trinkets:Array

var win_flow_started:bool = false
var is_mid_turn:bool = false: set = _set_is_mid_turn
var level_completed:bool = false

# From main_game:
var max_energy := 3
var _chapter:int = 0

func _ready() -> void:
	Events.request_add_tools_to_hand.connect(_on_request_add_tools_to_hand)
	Events.request_add_tools_to_discard_pile.connect(_on_request_add_tools_to_discard_pile)
	Events.request_modify_hand_cards.connect(_on_request_modify_hand_cards)
	Events.request_hp_update.connect(_on_request_hp_update)
	Events.request_energy_update.connect(_on_request_energy_update)
	gui.ui_lock_toggled.connect(_on_ui_lock_toggled)

func start(card_pool:Array[ToolData], energy_cap:int, combat:CombatData, chapter:int, player_data:PlayerData, trinket_datas:Array) -> void:

	session_summary = SessionSummary.new(combat)
	combat_queue_manager.setup(self)
	Events.request_combat_queue_push.connect(_on_request_combat_queue_push)

	plant_field_container.plant_bloom_completed.connect(_on_plant_bloom_completed)
	plant_field_container.plant_action_application_completed.connect(_on_plant_action_application_completed)
	plant_field_container.mouse_plant_updated.connect(_on_mouse_plant_updated)
	plant_field_container.plant_light_updated.connect(_on_plant_light_updated)
	plant_field_container.plant_water_updated.connect(_on_plant_water_updated)

	weather_main.weathers_updated.connect(_on_weathers_updated)
	weather_main.test_weather = test_weather

	tool_manager = ToolManager.new(card_pool.duplicate(), gui.gui_tool_card_container)
	tool_manager.tool_application_started.connect(_on_tool_application_started)
	tool_manager.tool_application_success.connect(_on_tool_application_success)
	tool_manager.tool_application_completed.connect(_on_tool_application_completed)
	tool_manager.tool_application_error.connect(_on_tool_application_error)
	tool_manager.hand_updated.connect(_on_hand_updated)
	tool_manager.cards_removed_from_hand.connect(_on_cards_removed_from_hand)
	tool_manager.max_hand_size_reached.connect(_on_max_hand_size_reached)
	tool_manager.pool_updated.connect(_on_pool_updated)
	tool_manager.tool_application_bailed.connect(_on_tool_application_bailed)

	gui.bind_energy(energy_tracker)
	gui.bind_tool_deck(tool_manager.tool_deck)
	gui.end_turn_button_pressed.connect(_on_end_turn_button_pressed)
	gui.main_card_selected.connect(_on_main_card_selected)
	gui.mouse_exited_card.connect(_on_mouse_exited_card)
	gui.reward_finished.connect(_on_reward_finished)

	player.field_index_updated.connect(_on_player_field_index_updated)
	player.player_upgrade_activated.connect(_on_player_player_upgrade_activated)
	player.player_upgrade_stack_updated.connect(_on_player_player_upgrade_stack_updated)

	combat_modifier_manager.setup(self)

	max_energy = energy_cap
	energy_tracker.capped = false

	background_music_player.volume_db = -80

	_combat = combat
	_chapter = chapter
	_owned_trinkets = trinket_datas
	player.setup(player_data, _combat.plants.size() - 1, _owned_trinkets)
	_start_new_level()

#endregion

#region player

func get_current_player_plant() -> Plant:
	return plant_field_container.get_plant(player.current_field_index)

#endregion

#region cards
func draw_cards(count:int) -> void:
	var first_turn_draw := day_manager.day == 0 && !is_mid_turn
	var draw_results:Array = await tool_manager.draw_cards(count, first_turn_draw, self)
	await player.player_upgrades_manager.handle_card_added_to_hand_hook(draw_results, self)
	await player.player_upgrades_manager.handle_draw_hook(self, draw_results)

func discard_cards(tools:Array) -> void:
	await tool_manager.discard_cards(tools, self)
	await player.player_upgrades_manager.handle_discard_hook(self, tools)

func exhaust_cards(tools:Array) -> void:
	await tool_manager.exhaust_cards(tools, self)
	await player.player_upgrades_manager.handle_exhaust_hook(self, tools)

func add_tools_to_hand(tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
	await player.player_upgrades_manager.handle_card_added_to_hand_hook(tool_datas, self)
	await tool_manager.add_tools_to_hand(tool_datas, from_global_position, pause, self)
#endregion

#region private
  
func _start_new_level() -> void:
	gui.toggle_all_ui(false)
	combat_modifier_manager.apply_modifiers(CombatModifier.ModifierTiming.LEVEL)
	boost = 1
	plant_field_container.setup_with_plants(_combat.plants)
	day_manager.start_new()
	gui.update_with_combat(_combat, self)
	level_started.emit()
	await weather_main.start(_chapter, _combat.combat_type)
	player.current_field_index = 0
	_start_turn()

func _start_turn() -> void:
	assert(gui.is_ui_locked(), "UI is not locked before start turn, this should not happen as it will cause a deadlock")
	combat_modifier_manager.apply_modifiers(CombatModifier.ModifierTiming.TURN)
	boost = maxi(boost - 1, 1)
	day_manager.next_day()
	weather_main.generate_next_weather_abilities(self, day_manager.day)
	if day_manager.day == 0:
		_fade_music(true)
		#await gui.apply_boss_actions(GUIBoss.HookType.LEVEL_START)
		energy_tracker.setup(max_energy, max_energy)
	#await gui.apply_boss_actions(GUIBoss.HookType.TURN_START)
	_queue_start_turn_draw_cards()
	player.queue_start_turn_hooks(self)
	plant_field_container.queue_start_turn_abilities(self)
	_queue_turn_start_signals()
	#_win()

func _queue_start_turn_draw_cards() -> void:
	var request = CombatQueueRequest.new()
	request.callback = func(cm: CombatMain) -> void: 
		var draw_count := hand_size + player.handle_hand_size(cm)
		await draw_cards(draw_count)
		is_mid_turn = true
	Events.request_combat_queue_push.emit(request)

func _queue_turn_start_signals() -> void:
	var request = CombatQueueRequest.new()
	request.callback = func(_cm: CombatMain) -> void: 
		gui.toggle_all_ui(true)
		turn_started.emit()
	Events.request_combat_queue_push.emit(request)

func _end_turn() -> void:
	is_mid_turn = false
	tool_manager.card_use_limit_reached = false
	energy_tracker.restore(energy_tracker.max_value - energy_tracker.value)
	player.queue_handle_turn_end(self)
	plant_field_container.queue_end_turn_abilities(self)
	weather_main.queue_weather_abilities()

	# Night fall
	_queue_night_fall()

	# Turn End Cards
	_queue_turn_end_cards()
	_queue_discard_all_cards(true)

	# Clean up and start new turn if not win
	_queue_end_turn_cleanup()

func _queue_night_fall() -> void:
	var night_fall_request = CombatQueueRequest.new()
	night_fall_request.callback = func(_cm: CombatMain) -> void: await weather_main.night_fall()
	Events.request_combat_queue_push.emit(night_fall_request)

func _queue_weather_start_new_day() -> void:
	var request = CombatQueueRequest.new()
	request.callback = func(_cm: CombatMain) -> void: await weather_main.new_day()
	Events.request_combat_queue_push.emit(request)

func _queue_start_turn() -> void:
	var request = CombatQueueRequest.new()
	request.callback = func(_cm: CombatMain) -> void: _start_turn()
	Events.request_combat_queue_push.emit(request)

func _queue_turn_end_cards() -> void:
	if tool_manager.tool_deck.hand.is_empty():
		return
	tool_manager.trigger_turn_end_cards(self)

func _met_win_condition() -> bool:
	return plant_field_container.are_all_plants_bloom()

func _queue_end_turn_cleanup() -> void:
	var request = CombatQueueRequest.new()
	request.callback = func(_cm: CombatMain) -> void: 
		tool_manager.cleanup_for_turn()
		combat_modifier_manager.clear_for_turn()
	request.finish_callback = func(_cm:CombatMain) -> void: 
		if _met_win_condition():
			# _win() is called by _bloom()
			return
		_queue_weather_start_new_day()
		_queue_start_turn()
	Events.request_combat_queue_push.emit(request)
	
func _queue_discard_all_cards(exclude_handy:bool) -> void:
	var request = CombatQueueRequest.new()
	request.callback = func(_cm: CombatMain) -> void:
		if tool_manager.tool_deck.hand.is_empty():
			return
		var cards_to_discard:Array = tool_manager.tool_deck.hand.duplicate().filter(func(tool_data:ToolData): return  !tool_data.specials.has(ToolData.Special.HANDY) if exclude_handy else true)
		if cards_to_discard.size() == 0:
			return
		await tool_manager.discard_cards(cards_to_discard, self)
	Events.request_combat_queue_push.emit(request)

func _win() -> void:
	if win_flow_started:
		return
	is_mid_turn = false
	win_flow_started = true
	gui.permanently_lock_all_ui()
	_fade_music(false)
	await player.player_upgrades_manager.handle_combat_end_hook(self)
	await Util.create_scaled_timer(WIN_PAUSE_TIME).timeout
	if _chapter == MainGame.NUMBER_OF_CHAPTERS - 1 && _combat.combat_type == CombatData.CombatType.BOSS:
		beat_final_boss.emit()
		level_completed = true
		return
	weather_main.level_end_stop()
	session_summary.total_days += day_manager.day
	_queue_discard_all_cards(false)
	_queue_show_reward()

func _queue_show_reward() -> void:
	var owned_trinket_ids: Array[String] = []
	for trinket: TrinketData in _owned_trinkets:
		owned_trinket_ids.append(trinket.id)
	var request = CombatQueueRequest.new()
	request.callback = func(_cm: CombatMain) -> void:
		level_completed = true
		gui.animate_show_reward_main(_combat, owned_trinket_ids)
	Events.request_combat_queue_push.emit(request)

func _clear_tool_selection() -> void:
	tool_manager.clear_tool_selection()
	gui.clear_tool_selection()
	plant_field_container.clear_tool_indicators()

func _bloom(plant_index:int) -> void:
	var field:Field = plant_field_container.get_field(plant_index)
	if field.can_bloom():
		field.bloom(self)

func _fade_music(fade_in:bool) -> void:
	if fade_in:
		background_music_player.play()
	var target_volume_db:float = 0 if fade_in else -80
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(background_music_player, "volume_db", target_volume_db, BACKGROUND_MUSIC_FADE_IN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	if !fade_in:
		background_music_player.stop()

func _queue_apply_tool(tool_data:ToolData) -> void:
	var tool_card:GUIToolCardButton = gui.gui_tool_card_container.find_card(tool_data)
	if !tool_card:
		return
	tool_manager.queue_apply_tool(self, tool_data)

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
func _on_main_card_selected(tool_data:ToolData) -> void:
	if !is_mid_turn:
		return
	var success:bool = gui.gui_tool_card_container.select_main_card(tool_data)
	if !success:
		return
	_queue_apply_tool(tool_data)

func _on_mouse_exited_card(tool_data:ToolData) -> void:
	_hide_custom_error(tool_data.id)

func _on_end_turn_button_pressed() -> void:
	if !is_mid_turn:
		return
	assert(!gui.is_ui_locked(), "UI is already locked before end turn, this should not happen as it will cause a deadlock")
	gui.toggle_all_ui(false)
	var request = CombatQueueRequest.new()
	request.callback = func(_cm: CombatMain) -> void: _end_turn()
	request.unique_id = END_TURN_UNIQUE_ID
	Events.request_combat_queue_push.emit(request)

func _on_reward_finished() -> void:
	if _combat.combat_type == CombatData.CombatType.BOSS:
		#beat demo
		pass # TODO: beat demo
	else:
		reward_finished.emit()

func _on_ui_lock_toggled(on:bool) -> void:
	player.toggle_ui_buttons(on)

func _on_player_field_index_updated(from:int, to:int) -> void:
	plant_field_container.update_player_index(to)
	var destination_x := plant_field_container.get_field(to).global_position.x
	player.move_to_x(destination_x)
	tool_manager.refresh_cards_ui(self)
	if from != to:
		player.player_upgrades_manager.queue_player_move_hooks(self)

#region other events

func _on_tool_application_started(tool_data:ToolData) -> void:
	gui.gui_tool_card_container.set_card_state(tool_data, GUICardFace.CardState.SELECTED)

func _on_tool_application_success(tool_data:ToolData) -> void:
	if tool_data.get_final_energy_cost() > 0:
		energy_tracker.spend(tool_data.get_final_energy_cost())

func _on_tool_application_completed(tool_data:ToolData) -> void:
	if tool_manager.number_of_card_used_this_turn >= combat_modifier_manager.card_use_limit():
		tool_manager.card_use_limit_reached = true
	await player.player_upgrades_manager.handle_tool_application_hook(self, tool_data)
	_clear_tool_selection()

func _on_tool_application_error(tool_data:ToolData, error_message:String) -> void:
	_clear_tool_selection()
	gui.reset_tool_positions()
	Events.request_show_custom_error.emit(error_message, tool_data.id)
	if _tool_application_error_timers.has(tool_data.id):
		var existing_timer:SceneTreeTimer = _tool_application_error_timers[tool_data.id]
		existing_timer.timeout.disconnect(_on_tool_application_error_timer_timeout)
	var timer:SceneTreeTimer = Util.create_scaled_timer(TOOL_APPLICATION_ERROR_HIDE_DELAY)
	_tool_application_error_timers[tool_data.id] = timer
	timer.timeout.connect(_on_tool_application_error_timer_timeout.bind(tool_data.id))

func _on_tool_application_error_timer_timeout(id:String) -> void:
	_hide_custom_error(id)

func _on_tool_application_bailed(tool_data:ToolData) -> void:
	if !tool_data:
		return
	gui.gui_tool_card_container.set_card_state(tool_data, GUICardFace.CardState.NORMAL)
	gui.gui_tool_card_container.animate_card_error_shake(tool_data)

func _on_max_hand_size_reached() -> void:
	Events.request_show_warning.emit(WarningManager.WarningType.MAX_HAND_SIZE_REACHED)
	if _max_hand_warning_timer:
		_max_hand_warning_timer.timeout.disconnect(_on_max_hand_warning_timer_timeout)
	_max_hand_warning_timer = Util.create_scaled_timer(MAX_HAND_WARNING_HIDE_DELAY)
	_max_hand_warning_timer.timeout.connect(_on_max_hand_warning_timer_timeout)

func _on_max_hand_warning_timer_timeout() -> void:
	_max_hand_warning_timer = null
	Events.request_hide_warning.emit(WarningManager.WarningType.MAX_HAND_SIZE_REACHED)

func _on_hand_updated(_hand:Array) -> void:
	tool_manager.refresh_cards_ui(self)

func _on_cards_removed_from_hand(_tool_datas:Array, _updated_hand:Array) -> void:
	if is_mid_turn:
		player.player_upgrades_manager.queue_hand_updated_hooks(self)

func _on_plant_action_application_completed(index:int) -> void:
	_bloom(index)

func _on_plant_bloom_completed(_plant:Plant) -> void:
	player.player_upgrades_manager.queue_plant_bloom_hooks(self)
	if _met_win_condition():
		await _win()

func _on_weathers_updated() -> void:
	gui.update_weathers(weather_main.weather_manager)

func _on_mouse_plant_updated(_plant:Plant) -> void:
	pass

func _on_request_add_tools_to_hand(tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
	gui.toggle_all_ui(false)
	await add_tools_to_hand(tool_datas, from_global_position, pause)
	gui.toggle_all_ui(true)

func _on_request_add_tools_to_discard_pile(tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
	gui.toggle_all_ui(false)
	await tool_manager.add_tools_to_discard_pile(tool_datas, from_global_position, pause, self)
	gui.toggle_all_ui(true)

func _on_request_modify_hand_cards(callable:Callable) -> void:
	gui.toggle_all_ui(false)
	await callable.call(tool_manager.tool_deck.hand)
	tool_manager.refresh_cards_ui(self)
	gui.toggle_all_ui(true)

func _on_request_combat_queue_push(request) -> void:
	if level_completed:
		return
	combat_queue_manager.push_request(request)

func _on_request_hp_update(val:int, operation:ActionData.OperatorType) -> void:
	# The hp is handled by the main game
	player.update_hp(val, operation)
	if operation == ActionData.OperatorType.DECREASE:
		player.player_upgrades_manager.handle_damage_taken_hook(self, abs(val))

func _on_request_energy_update(val:int, operation:ActionData.OperatorType) -> void:
	match operation:
		ActionData.OperatorType.INCREASE:
			energy_tracker.restore(val)
		ActionData.OperatorType.DECREASE:
			energy_tracker.spend(val)
		ActionData.OperatorType.EQUAL_TO:
			energy_tracker.value = val
	player.update_energy(val, operation)

func _on_player_player_upgrade_activated(player_upgrade:PlayerUpgrade) -> void:
	player_upgrade.handle_activation_hook(self)

func _on_player_player_upgrade_stack_updated(id:String, diff:int) -> void:
	player.player_upgrades_manager.handle_stack_update_hook(self, id, diff)

func _on_pool_updated(pool:Array) -> void:
	await player.player_upgrades_manager.handle_pool_updated_hook(self, pool)

func _on_plant_light_updated(_plant:Plant, _from_value:int, _to_value:int) -> void:
	tool_manager.refresh_cards_ui(self)

func _on_plant_water_updated(_plant:Plant, _from_value:int, _to_value:int) -> void:
	tool_manager.refresh_cards_ui(self)

#endregion

#region setter/getter

func _set_boost(val:int) -> void:
	boost = val
	gui.update_boost(boost)

func _set_is_mid_turn(value:bool) -> void:
	is_mid_turn = value
	gui.gui_tool_card_container.is_mid_turn = value
	tool_manager.is_mid_turn = value

#endregion
