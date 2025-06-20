class_name BingoController
extends Node

const SPACE_BINGO_ANIMATION_DURATION:float = 0.3
const HP_UPDATE_DURATION:float = 0.2
const DISPLAY_DURATION:float = 0.15
const ENEMY_PLAYER_TURN_DELAY:float = 0.2

enum DisplayBallType {
	ENEMY,
	PLAYER,
	SUMMON,
}

enum CheckBingoResult {
	SUCCESS,
	PLAYER_DIED,
	ENEMY_DIED,
}

enum OperationType {
	NONE,
	TURN_DRAWING,
	OTHER_DRAWING,
	DISPLAY_POWER_SYMBOL,
}

signal player_died()
signal enemy_died()

#signal all_bingos_completed()
#signal one_bingo_completed(bingo_results:Array[BingoResult], result_index:int)
#signal signal_player_died()
signal _one_draw_event_finished()
signal _all_draw_events_finished()
signal _draw_player_card_finished()
signal _display_one_player_ball_finished()
signal _display_all_player_balls_finished()
signal _discard_balls_finished()
signal _display_one_enemy_ball_finished()
signal _display_one_enemy_ball_type_finished()
signal _one_enemy_turn_finished()
signal _all_enemy_turns_finished()
signal _one_space_all_bingo_event_finished()
signal _all_bingo_events_finished()
signal _one_space_script_finished()
signal _one_bingo_result_finished()
signal _all_bingo_results_finished()
signal draw_sequence_finished()

signal _one_summon_ball_finished()
signal _all_summon_balls_finished()
signal summon_ball_operation_finished()

signal _remove_one_ball_finished(is_bingo:bool)
signal _remove_all_balls_finished()
signal remove_ball_operation_finished()

signal _display_power_symbol_finished()
signal display_power_symbol_operation_finished()

var _bingo_board:BingoBoard
var _gui_bingo_main:GUIBingoMain

var _player:Player: get = _get_player
var _enemy_controller:EnemyController: get = _get_enemy_controller

var _weak_player:WeakRef = weakref(null)
var _weak_enemy_controller:WeakRef = weakref(null)

# State parameters
var _display_index := -1
var _draw_event_index:int = -1
var _enemy_index:int = -1
var _enemy_ball_type_index:int = -1
var _enemy_ball_index:int = -1
var _enemy_attack_result:Array = []
var _bingo_results:Array[BingoResult] = []
var _bingo_result_index:int = -1
var _bingo_result_space_index:int = -1
var _all_bingo_events_index:int = -1
var _operation_type_queue:Array[OperationType] = []
var _removing_ball_indexes:Array = []
var _removing_ball_index:int = -1
var _summoning_ball_datas:Array = []
var _summoning_ball_index := -1
var _summoning_ball_desired_space_index:int = -1
var _summoning_ball_from_space_index:int = -1

func _init(bingo_board:BingoBoard, gui_bingo_main:GUIBingoMain, player:Player, enemy_controller:EnemyController) -> void:
	_bingo_board = bingo_board
	_gui_bingo_main = gui_bingo_main
	_weak_player = weakref(player)
	_weak_enemy_controller = weakref(enemy_controller)
	_one_draw_event_finished.connect(_on_one_draw_event_finished)
	_all_draw_events_finished.connect(_on_all_draw_events_finished)
	_draw_player_card_finished.connect(_on_draw_player_card_finished)
	_display_one_player_ball_finished.connect(_on_display_one_player_ball_finished)
	_display_all_player_balls_finished.connect(_on_display_all_player_balls_finished)
	_discard_balls_finished.connect(_on_discard_balls_finished)
	_display_one_enemy_ball_finished.connect(_on_display_one_enemy_ball_finished)
	_display_one_enemy_ball_type_finished.connect(_on_display_one_enemy_ball_type_finished)
	_display_power_symbol_finished.connect(_on_display_power_symbol_finished)
	_one_enemy_turn_finished.connect(_on_one_enemy_turn_finished)
	_all_enemy_turns_finished.connect(_on_all_enemy_turns_finished)
	_one_space_all_bingo_event_finished.connect(_on_one_space_all_bingo_event_finished)
	_all_bingo_results_finished.connect(_on_all_bingo_results_finished)
	_one_space_script_finished.connect(_on_one_space_script_finished)
	_all_bingo_events_finished.connect(_on_all_bingo_events_finished)
	_one_bingo_result_finished.connect(_on_one_bingo_result_finished)
	_remove_all_balls_finished.connect(_on_remove_all_balls_finished)
	_remove_one_ball_finished.connect(_on_remove_one_ball_finished)
	_all_summon_balls_finished.connect(_on_all_summon_balls_finished)
	_one_summon_ball_finished.connect(_on_one_summon_ball_finished)
	

func reset_new_combat() -> void:
	pass

func discard_balls() -> void:
	if _player.draw_box.hand.size() == 0:
		return
	await _gui_bingo_main.gui_animation_container.animate_discard(_player.draw_box.hand)
	_gui_bingo_main.clear_bingo_ball_warnings()
	_player.discard_balls()
	_discard_balls_finished.emit()

func shuffle() -> void:
	var discard_pile_balls := _player.draw_box.discard_pool.duplicate()
	await _gui_bingo_main.gui_animation_container.animate_shuffle(discard_pile_balls)
	_player.shuffle_draw_box()

#region Drawing flow

# Hand draw is the draw for each turn. (When draw button is pressed). The number of balls to draw is determined by the intended draw count from player data and modifiers from certain buffs.
# If hand draw is false, , alternative_number_to_draw is determined to be the number of balls to draw, this ignores player data and modifiers.
func start_draw() -> void:
	_operation_type_queue.push_back(OperationType.TURN_DRAWING)
	await _player.status_effect_manager.on_predraw()
	_enemy_controller.get_current_enemy().status_effect_manager.on_predraw()
	_draw_player_cards(_player.get_intended_draw_count())

func start_other_draw(number_to_draw:int) -> void:
	_operation_type_queue.push_back(OperationType.OTHER_DRAWING)
	await _draw_player_cards(number_to_draw)

func _draw_player_cards(number_to_draw:int) -> void:
	if _display_index == -1:
		_display_index = _player.draw_box.hand.size() - 1
	_gui_bingo_main._gui_bingo_ball_hand.show()
	var player_draw_results:Array[BingoBallData] = _player.draw_balls(number_to_draw)
	await _gui_bingo_main.gui_animation_container.animate_draw(player_draw_results)
	_gui_bingo_main._gui_bingo_ball_hand.add_balls(player_draw_results)
	if player_draw_results.size() < number_to_draw:
		# If no sufficient balls in draw pool, shuffle discard pile and draw again.
		await shuffle()
		var second_draw_result := _player.draw_balls(number_to_draw - player_draw_results.size())
		await _gui_bingo_main.gui_animation_container.animate_draw(second_draw_result)
		_gui_bingo_main._gui_bingo_ball_hand.add_balls(second_draw_result)
	_draw_player_card_finished.emit()

func _on_draw_player_card_finished() -> void:
	_player.status_effect_manager.on_draw()
	_enemy_controller.get_current_enemy().status_effect_manager.on_draw()
	if _display_index == -1:
		_display_next_player_ball()

func _display_next_player_ball() -> void:
	_display_index += 1
	if _display_index >= _player.draw_box.hand.size():
		_display_all_player_balls_finished.emit()
		return
	var ball_data:BingoBallData = _player.draw_box.hand[_display_index]
	var board_index := _bingo_board.find_display_ball_space(ball_data)
	if board_index >= 0:
		await _gui_bingo_main.gui_animation_container.animate_symbol_move_from_draw_box_to_board(ball_data, _display_index, board_index, DISPLAY_DURATION)
		await _display_one_ball(ball_data, board_index, true)
	else:
		var gui_bingo_ball = _gui_bingo_main._gui_bingo_ball_hand.get_ball(_display_index)
		await gui_bingo_ball.animate_no_space(DISPLAY_DURATION * 2)
		gui_bingo_ball.display_no_space_warning_tooltip()
	_display_one_player_ball_finished.emit()

func _on_display_one_player_ball_finished() -> void:
	if await _check_interrupts():
		return
	_display_next_player_ball()

func _on_display_all_player_balls_finished() -> void:
	var current_operation_type:OperationType = _get_operation_type()
	if current_operation_type == OperationType.TURN_DRAWING:
		_display_index = -1
		_handle_draw_events()
	elif current_operation_type == OperationType.OTHER_DRAWING:
		_operation_type_queue.pop_back()
		_on_display_all_player_balls_finished()

func _handle_draw_events() -> void:
	_handle_draw_event_for_next_space()

func _handle_draw_event_for_next_space() -> void:
	_draw_event_index += 1
	if _draw_event_index >= _bingo_board.board.size():
		_draw_event_index = -1
		_all_draw_events_finished.emit()
		return
	var space:BingoSpaceData = _bingo_board.board[_draw_event_index]
	if space.ball_script:
		await space.ball_script.animate_handle_draw()
	_one_draw_event_finished.emit()

func _on_one_draw_event_finished() -> void:
	if await _check_interrupts():
		return
	_handle_draw_event_for_next_space()

func _on_all_draw_events_finished() -> void:
	_start_enemy_turn()

func _start_enemy_turn() -> void:
	if _enemy_controller.get_current_enemy().is_died:
		return
	_enemy_index = 0
	_handle_enemy_turn_for_next_enemy()

func _handle_enemy_turn_for_next_enemy() -> void:		
	var enemy := _enemy_controller.get_active_enemies()[_enemy_index]
	var attack_counter_gain := 1
	_enemy_attack_result = enemy.animate_increase_attack_counters(attack_counter_gain, 0.2)
	if _enemy_attack_result.is_empty():
		_one_enemy_turn_finished.emit()
	else:
		await Util.create_scaled_timer(ENEMY_PLAYER_TURN_DELAY).timeout
		_display_balls_for_next_enemy()

func _display_balls_for_next_enemy() -> void:
	assert(_enemy_attack_result.size() > 0)
	_enemy_ball_type_index = -1
	_display_next_enemy_ball_type()

func _display_next_enemy_ball_type() -> void:
	_enemy_ball_type_index += 1
	if _enemy_ball_type_index >= _enemy_attack_result.size():
		_one_enemy_turn_finished.emit()
		return
	_enemy_ball_index = -1
	_display_next_enemy_ball()

func _display_next_enemy_ball() -> void:
	_enemy_ball_index += 1
	if _enemy_ball_index >= _enemy_attack_result[_enemy_ball_type_index].size():
		_display_one_enemy_ball_type_finished.emit()
		return
	var enemy := _enemy_controller.get_active_enemies()[_enemy_index]
	assert(_enemy_attack_result.size() > 0)
	var ball_data:BingoBallData = _enemy_attack_result[_enemy_ball_type_index][_enemy_ball_index]
	var board_index := _bingo_board.find_display_ball_space(ball_data)
	if board_index >= 0:
		await _gui_bingo_main.gui_animation_container.animate_symbol_move_from_enemy_to_board(enemy, ball_data, board_index, DISPLAY_DURATION)
		await _display_one_ball(ball_data, board_index, true)
	else:
		var gui_bingo_ball = _gui_bingo_main._gui_enemy_container._gui_enemy_box.get_attack_bingo_ball(ball_data)
		await gui_bingo_ball.animate_no_space(DISPLAY_DURATION * 2)
		gui_bingo_ball.display_no_space_warning_tooltip()
	_display_one_enemy_ball_finished.emit()

func _on_display_one_enemy_ball_finished() -> void:
	if await _check_interrupts():
		return
	_display_next_enemy_ball()

func _on_display_one_enemy_ball_type_finished() -> void:
	var enemy := _enemy_controller.get_active_enemies()[_enemy_index]
	var ball_data:BingoBallData = _enemy_attack_result[_enemy_ball_type_index][0]
	await enemy.animate_reset_attack_counter(ball_data.base_id, 0)
	_display_next_enemy_ball_type()

func _on_one_enemy_turn_finished() -> void:
	_enemy_index += 1
	if _enemy_index >= _enemy_controller.get_active_enemies().size():
		_all_enemy_turns_finished.emit()
		return
	_handle_enemy_turn_for_next_enemy()

func _on_all_enemy_turns_finished() -> void:
	#await _enemy_controller.handle_draw()
	discard_balls()

func _on_discard_balls_finished() -> void:
	_check_bingo()

func _finish_draw_sequence() -> void:
	await _cleanup()
	draw_sequence_finished.emit()

func _reset() -> void:
	_clean_up_operations()
	await _cleanup()

func _cleanup() -> void:
	_display_index = -1
	_draw_event_index = -1
	_enemy_index = -1
	_enemy_ball_index = -1
	_bingo_results.clear()
	_bingo_result_index = -1
	_bingo_result_space_index = -1
	_all_bingo_events_index = -1
	_enemy_attack_result.clear()
	_summoning_ball_datas.clear()
	_summoning_ball_index = -1
	_summoning_ball_desired_space_index = -1
	_summoning_ball_from_space_index = -1
	if !_player.draw_box.hand.is_empty():
		await discard_balls()

func _clean_up_operations() -> void:
	for operation_type:OperationType in _operation_type_queue:
		_finish_operation()

#endregion

#region Bingo check flow

func _find_new_bingo_results() -> Array:
	assert(_bingo_results.is_empty())
	return _bingo_board.check_bingo()

func _check_bingo() -> void:
	var new_bingo_results := _find_new_bingo_results()
	if new_bingo_results.is_empty():
		_all_bingo_results_finished.emit()
		return
	_bingo_results = new_bingo_results
	_handle_next_bingo_result()

func _handle_next_bingo_result() -> void:
	_bingo_result_index += 1
	#print("=========== _handle_next_bingo_result ======== ", str(_bingo_result_index + 1), "/", _bingo_results.size())
	if _bingo_result_index >= _bingo_results.size():
		_all_bingo_results_finished.emit()
		return
	var bingo_result:BingoResult = _bingo_results[_bingo_result_index]
	await _gui_bingo_main.gui_animation_container.animate_bingo(bingo_result)
	_handle_all_bingo_events()

func _handle_all_bingo_events() -> void:
	#print("=========== _handle_all_bingo_events ======== ")
	_all_bingo_events_index = -1
	_handle_all_bingo_event_for_next_space()

func _handle_all_bingo_event_for_next_space() -> void:
	_all_bingo_events_index += 1
	if _all_bingo_events_index >= _bingo_board.board.size():
		_all_bingo_events_index = -1
		_all_bingo_events_finished.emit()
		return
	var bingo_result:BingoResult = _bingo_results[_bingo_result_index]
	var space:BingoSpaceData = _bingo_board.board[_all_bingo_events_index]
	if space.ball_script && space.ball_script.has_all_bingo_events(bingo_result):
		await space.ball_script.handle_all_bingo(bingo_result)
	_one_space_all_bingo_event_finished.emit()

func _on_one_space_all_bingo_event_finished() -> void:
	if await _check_interrupts():
		return
	_handle_all_bingo_event_for_next_space()

func _on_all_bingo_events_finished() -> void:
	_bingo_result_space_index = -1
	_handle_next_space_bingo()

func _handle_next_space_bingo() -> void:
	#print("=========== _handle_next_space_bingo ======== ", str(_bingo_result_index+1), "/", str(_bingo_results[_bingo_result_index].spaces.size()), " -> ", str(_bingo_result_space_index))
	_bingo_result_space_index += 1
	if _bingo_result_space_index >= _bingo_results[_bingo_result_index].spaces.size():
		_one_bingo_result_finished.emit()
		return
	var bingo_result:BingoResult = _bingo_results[_bingo_result_index]
	var space:BingoSpaceData = bingo_result.spaces[_bingo_result_space_index]
	await handle_one_space_bingo(space, bingo_result)
	_one_space_script_finished.emit()

func _on_one_space_script_finished() -> void:
	if await _check_interrupts():
		return
	_handle_next_space_bingo()

func _on_one_bingo_result_finished() -> void:
	_handle_next_bingo_result()

func _on_all_bingo_results_finished() -> void:
	if !_bingo_results.is_empty():
		_handle_display_sequence_end()
		await _remove_spaces_for_bingo()
		_check_bingo()
	else:
		_finish_operation()

func _finish_operation() -> void:
	match _get_operation_type():
		OperationType.TURN_DRAWING:
			_finish_draw_sequence()
			_operation_type_queue.pop_back()
		OperationType.OTHER_DRAWING:
			_finish_draw_sequence()
			_operation_type_queue.pop_back()
		OperationType.DISPLAY_POWER_SYMBOL:
			display_power_symbol_operation_finished.emit()
			_operation_type_queue.pop_back()
		OperationType.NONE:
			pass

func _refresh_bingo_board(animated:bool = false) -> void:
	_bingo_board.generate()
	await _gui_bingo_main.refresh_with_board(_bingo_board, animated)

func _remove_spaces_for_bingo() -> void:
	var removing_indexes:Array[int] = []
	for bingo_result:BingoResult in _bingo_results:
		for space:BingoSpaceData in bingo_result.spaces:
			removing_indexes.append(space.index)
	handle_remove_balls_from_board(removing_indexes)
	await remove_ball_operation_finished
	_end_bingo_flow()

func _end_bingo_flow() -> void:
	_bingo_results.clear()
	_bingo_result_index = -1
#endregion

#region move balls flow

func handle_move_balls(from_indexes:Array, to_indexes:Array) -> void:
	_gui_bingo_main.gui_animation_container.animate_move_balls(from_indexes, to_indexes)
	for i in from_indexes.size():
		var from_index:int = from_indexes[i]
		_gui_bingo_main._gui_bingo_board.display_ball(null, from_index)
	await _gui_bingo_main.gui_animation_container.move_animation_finished
	for i in from_indexes.size():
		var from_index:int = from_indexes[i]
		var to_index:int = to_indexes[i]
		var ball_data:BingoBallData = _bingo_board.board[from_index].ball_data
		# Ball needs to be removed before displaying for not creating a duplicate situation
		_remove_one_ball(from_index)
		await _display_one_ball(ball_data, to_index, false)

#endregion

#region Remove balls flow

func handle_remove_balls_from_board(indexes:Array) -> void:
	_removing_ball_indexes.append_array(indexes.duplicate())
	_removing_ball_indexes = Util.remove_duplicates_from_array(_removing_ball_indexes)
	if _removing_ball_indexes.is_empty():
		remove_ball_operation_finished.emit()
		return
	_handle_remove_next_ball()

func _handle_remove_next_ball() -> void:
	_removing_ball_index += 1
	if _removing_ball_index >= _removing_ball_indexes.size():
		_remove_all_balls_finished.emit()
		return
	var index:int = _removing_ball_indexes[_removing_ball_index]
	_remove_one_ball(index)
	_remove_one_ball_finished.emit()

func _remove_one_ball(index:int) -> void:
	var ball_data:BingoBallData = _bingo_board.board[index].ball_data
	if ball_data:
		_bingo_board.remove_ball(index)
		if ball_data.ball_script:
			ball_data.ball_script.handle_removed_from_board()

func _on_remove_one_ball_finished() -> void:
	_handle_remove_next_ball()

func _on_remove_all_balls_finished() -> void:
	var removing_indexes:Array = Util.remove_duplicates_from_array(_removing_ball_indexes)
	_removing_ball_indexes.clear()
	_removing_ball_index = -1
	_gui_bingo_main.gui_animation_container.animate_remove_balls_from_board(removing_indexes)
	await _gui_bingo_main.gui_animation_container.removal_animation_finished
	remove_ball_operation_finished.emit()

#endregion

#region Space handle flow

func handle_one_space_bingo(space:BingoSpaceData, bingo_result:BingoResult) -> bool:
	await space.handle_space_effect_bingo_event(bingo_result)
	var has_power_up:bool = space.ball_script && space.ball_script.has_power_up(bingo_result)
	var animation_time := SPACE_BINGO_ANIMATION_DURATION
	if space.ball_data.trigger_times > 1:
		animation_time = SPACE_BINGO_ANIMATION_DURATION * 0.7
	for i in space.ball_data.trigger_times:
		match space.ball_data.type:
			BingoBallData.Type.ATTACK:
				await _gui_bingo_main.gui_animation_container.animate_symbol_attack(space, has_power_up, animation_time)
		if space.ball_data.type == BingoBallData.Type.ATTACK:
			var target_character:Character
			var attack:Attack
			match space.ball_data.team:
				BingoBallData.Team.PLAYER:
					target_character = _enemy_controller.get_current_enemy()
				BingoBallData.Team.ENEMY:
					target_character = _player
			attack = space.generate_attack(target_character, bingo_result)
			var character_died := await _animate_receive_attack(target_character, attack)
			if character_died:
				return true
	if space.ball_script:
		await space.ball_script.handle_self_bingo_events(bingo_result)
	return false

#endregion


#region place ball flow

func place_power_symbol(power_data:BingoBallData, space_index:int) -> void:
	_operation_type_queue.append(OperationType.DISPLAY_POWER_SYMBOL)
	await _display_one_ball(power_data, space_index, true)
	_display_power_symbol_finished.emit()

func _on_display_power_symbol_finished() -> void:
	if await _check_interrupts():
		_operation_type_queue.pop_back()
		display_power_symbol_operation_finished.emit()
		return
	_check_bingo()

#endregion

#region summon balls flow

func summon_balls_from_space(ball_datas:Array, from_space_index:int, desired_space_index:int = -1) -> void:
	_summoning_ball_datas = ball_datas
	_summoning_ball_index = -1
	_summoning_ball_desired_space_index = desired_space_index
	_summoning_ball_from_space_index = from_space_index
	await Util.await_for_tiny_time() # Make this async
	_summon_next_ball()

func _summon_next_ball() -> void:
	_summoning_ball_index += 1
	if _summoning_ball_index >= _summoning_ball_datas.size():
		_all_summon_balls_finished.emit()
		return
	var ball_data:BingoBallData = _summoning_ball_datas[_summoning_ball_index]
	var board_index := _bingo_board.find_display_ball_space(ball_data)
	if board_index >= 0:
		await _gui_bingo_main.gui_animation_container.animate_summon_symbol(ball_data, board_index, _summoning_ball_from_space_index, DISPLAY_DURATION)
		await _display_one_ball(ball_data, board_index, true)
	_one_summon_ball_finished.emit()
	
func _on_one_summon_ball_finished() -> void:
	if await _check_interrupts():
		return
	_summon_next_ball()

func _on_all_summon_balls_finished() -> void:
	_summoning_ball_datas.clear()
	_summoning_ball_index = -1
	_summoning_ball_desired_space_index = -1
	_summoning_ball_from_space_index = -1
	summon_ball_operation_finished.emit()

#endregion

#region player lose hp flow

func handle_all_ball_for_player_lose_hp_event(damage:Damage) -> void:
	for space:BingoSpaceData in _bingo_board.board:
		if !space.ball_script:
			continue
		space.ball_script.handle_player_lost_hp(damage)

#endregion

#region helpers
func _check_interrupts() -> bool:
	if _player.is_died:
		await _reset()
		player_died.emit()
		return true
	elif _enemy_controller.get_current_enemy().is_died:
		await _reset()
		await _refresh_bingo_board(true)
		enemy_died.emit()
		return true
	return false

func _display_one_ball(ball_data:BingoBallData, desired_board_index:int, duplicate_ball_data:bool) -> void:
	assert(desired_board_index >= 0)
	var ball_data_to_display:BingoBallData = ball_data
	if duplicate_ball_data:
		ball_data_to_display = ball_data.get_duplicate()
	_bingo_board.display_one_ball(ball_data_to_display, desired_board_index)
	var space:BingoSpaceData = _bingo_board.board[desired_board_index]
	_gui_bingo_main._gui_bingo_board.display_ball(ball_data_to_display, desired_board_index)
	await _handle_post_symbol_display(space)

func _handle_post_symbol_display(space:BingoSpaceData) -> void:
	if space.ball_script:
		await space.ball_script.handle_placed_on_board()
	for bingo_space in _bingo_board.board:
		if bingo_space.index == space.index || bingo_space.ball_script == null:
			continue
		await bingo_space.ball_script.handle_other_symbol_replacement(space)
		if _sequence_should_end():
			return

func _animate_receive_attack(character:Character, attack:Attack) -> bool:
	if character.hp.value <= attack.damage:
		await character.animate_receive_attack(attack, HP_UPDATE_DURATION)
		_handle_display_sequence_end()
		return true
	else:
		character.animate_receive_attack(attack, HP_UPDATE_DURATION)
		return false

func _sequence_should_end() -> bool:
	return _player.is_died || _enemy_controller.get_current_enemy().is_died

func _handle_display_sequence_end() -> void:
	_player.end_damage_sequence()
	for character:Character in _enemy_controller.get_active_enemies():
		character.end_damage_sequence()

func _get_operation_type() -> OperationType:
	if _operation_type_queue.is_empty():
		return OperationType.NONE
	return _operation_type_queue.back()

func _has_operation_type(operation_type:OperationType) -> bool:
	return _operation_type_queue.has(operation_type)

#endregion

#region getter/

func _get_player() -> Player:
	return _weak_player.get_ref()

func _get_enemy_controller() -> EnemyController:
	return _weak_enemy_controller.get_ref()
#endregion
