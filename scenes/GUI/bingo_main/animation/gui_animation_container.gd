class_name GUIAnimationContainer
extends Control

const GUI_SYMBOL_SCENE := preload("res://scenes/GUI/bingo_main/shared/gui_symbol.tscn")
const GUI_ANIMATING_BINGO_BALL_SCENE := preload("res://scenes/GUI/bingo_main/draw_box/gui_animating_bingo_ball.tscn")
const BINGO_ANIMATION_TIME := 0.5
const CONSECUTIVE_BINGO_ANIMATION_SCALE := 0.03
const MINIMUM_ANIMATION_SCALE := 0.6
const ATTACK_BAR_SYMBOL_INITIAL_SCALE := 0.5
const DRAW_ANIMATION_TIME := 0.2
const DISCARD_ANIMATION_TIME := 0.1

signal removal_animation_finished()
signal move_animation_finished()

var _gui_bingo_main:GUIBingoMain: get = _get_gui_bingo_main

var _weak_gui_bingo_main = weakref(null)
var _removal_count:int = 0
var _move_count:int = 0

func setup(gui_bingo_main:GUIBingoMain) -> void:
	_weak_gui_bingo_main = weakref(gui_bingo_main)

func animate_draw(player_draw_results:Array[BingoBallData]) -> void:
	if player_draw_results.is_empty():
		return
	var ball_positions := _gui_bingo_main._gui_bingo_ball_hand.calculate_positions(_gui_bingo_main._gui_bingo_ball_hand.get_ball_count() + player_draw_results.size())
	var starting_index := _gui_bingo_main._gui_bingo_ball_hand.get_ball_count()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	var animating_balls:Array[GUIAnimatingBingoBall] = []
	var total_ball_count := _gui_bingo_main._gui_bingo_ball_hand.get_ball_count() + player_draw_results.size()
	for i in total_ball_count:
		var animating_ball:GUIAnimatingBingoBall = GUI_ANIMATING_BINGO_BALL_SCENE.instantiate()
		# var original_size:Vector2 = animating_ball.size
		add_child(animating_ball)
		animating_ball.hide()
		var ball_data:BingoBallData = null
		var initial_scale := 0.4
		if i >= starting_index:
			ball_data = player_draw_results[i - starting_index]
			animating_ball.global_position = _gui_bingo_main._gui_draw_box_button.global_position + _gui_bingo_main._gui_draw_box_button.size/2 - animating_ball.size/2*initial_scale
			animating_ball.scale = Vector2.ONE * initial_scale
		else:
			ball_data = _gui_bingo_main._gui_bingo_ball_hand.get_ball(i)._ball_data
			animating_ball.global_position = _gui_bingo_main._gui_bingo_ball_hand.get_ball(i).global_position
			_gui_bingo_main._gui_bingo_ball_hand.get_ball(i).hide()
		animating_ball.bind_bingo_ball(ball_data)
		var delay_index := i - starting_index + 1
		if delay_index >= 0:
			Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * delay_index).timeout.connect(func(): animating_ball.play_move_sound())
		var ball_local_position:Vector2 = ball_positions[i]
		var target_global_position:Vector2 = _gui_bingo_main._gui_bingo_ball_hand.global_position + ball_local_position
		tween.tween_property(animating_ball, "visible", true, 0.01).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(animating_ball, "global_position", target_global_position, DRAW_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(animating_ball, "scale", Vector2.ONE, DRAW_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * delay_index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		animating_balls.append(animating_ball)
	await tween.finished
	for animating_ball in animating_balls:
		animating_ball.queue_free()

func animate_discard(player_hand:Array[BingoBallData]) -> void:
	var index := 0
	var animating_balls:Array[GUIAnimatingBingoBall] = []
	for ball_data in player_hand:
		var animating_ball:GUIAnimatingBingoBall = GUI_ANIMATING_BINGO_BALL_SCENE.instantiate()
		add_child(animating_ball)
		animating_ball.bind_bingo_ball(ball_data)
		animating_ball.global_position = _gui_bingo_main._gui_bingo_ball_hand.get_ball(index).global_position
		animating_balls.append(animating_ball)
		index += 1
	_gui_bingo_main._gui_bingo_ball_hand.clear()
	index = 0
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for animating_ball in animating_balls:
		var target_scale := 0.4
		var target_position := _gui_bingo_main._gui_discard_box_button.global_position + _gui_bingo_main._gui_discard_box_button.size/2 - animating_ball.size/2*target_scale
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * index).timeout.connect(func(): animating_ball.play_move_sound())
		tween.tween_property(animating_ball, "global_position", target_position, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(animating_ball, "scale", Vector2.ONE * target_scale, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * index).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		index += 1
	await tween.finished
	for animating_ball in animating_balls:
		animating_ball.queue_free()

func animate_shuffle(shuffled_balls:Array[BingoBallData]) -> void:
	if shuffled_balls.size() == 0:
		return
	var index := 0
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for ball_data in shuffled_balls:
		var animating_ball:GUIAnimatingBingoBall = GUI_ANIMATING_BINGO_BALL_SCENE.instantiate()
		add_child(animating_ball)
		animating_ball.global_position = _gui_bingo_main._gui_discard_box_button.global_position
		var target_position := _gui_bingo_main._gui_draw_box_button.global_position
		var original_size:Vector2 = animating_ball.size
		animating_ball.scale = _gui_bingo_main._gui_discard_box_button.size/original_size
		animating_ball.bind_bingo_ball(ball_data)
		Util.create_scaled_timer(Constants.CARD_ANIMATION_DELAY * index - 0.01).timeout.connect(func(): animating_ball.play_move_sound())
		var tweener := tween.tween_property(animating_ball, "global_position", target_position, DISCARD_ANIMATION_TIME).set_delay(Constants.CARD_ANIMATION_DELAY * index)
		tweener.finished.connect(func():
			animating_ball.queue_free()
		)
		index += 1
	await tween.finished

func animate_bingo(bingo_result:BingoResult) -> void:
	var gui_spaces := []
	for space in bingo_result.spaces:
		gui_spaces.append(_gui_bingo_main._gui_bingo_board.get_space(space.index))
	for gui_space in gui_spaces:
		gui_space.animate_bingo(BINGO_ANIMATION_TIME)
	await Util.create_scaled_timer(BINGO_ANIMATION_TIME + 0.2).timeout

func animate_symbol_move_from_enemy_to_board(enemy:Enemy, ball_data:BingoBallData, board_index:int, time:float = 0.3) -> void:
	var attack_bar:GUIAttackBar = (enemy._box as GUIEnemyBox).get_attack_bars()[ball_data.base_id]
	var from_position:Vector2 = attack_bar.get_symbol_position()
	var to_position:Vector2 = _gui_bingo_main._gui_bingo_board.get_ball_position(board_index)
	await _animation_symbol_move(ball_data, from_position, to_position, ATTACK_BAR_SYMBOL_INITIAL_SCALE, time)

func animate_symbol_move_from_minion_to_board(ball_data:BingoBallData, board_index:int, time:float = 0.3) -> void:
	var attack_bar:GUIAttackBar = _gui_bingo_main._gui_minion_box.get_attack_bars()[ball_data.base_id]
	var from_position:Vector2 = attack_bar.get_symbol_position()
	var to_position:Vector2 = _gui_bingo_main._gui_bingo_board.get_ball_position(board_index)
	await _animation_symbol_move(ball_data, from_position, to_position, ATTACK_BAR_SYMBOL_INITIAL_SCALE, time)

func animate_symbol_move_from_draw_box_to_board(ball_data:BingoBallData, draw_box_index:int, board_index:int, time:float = 0.3) -> void:
	var from_position:Vector2 = _gui_bingo_main._gui_bingo_ball_hand.get_ball_position(draw_box_index)
	var to_position:Vector2 = _gui_bingo_main._gui_bingo_board.get_ball_position(board_index)
	await _animation_symbol_move(ball_data, from_position, to_position, 1.0, time)

func animate_summon_symbol(ball_data:BingoBallData, board_index:int, from_space_index:int, time:float = 0.3) -> void:
	var from_position:Vector2 = _gui_bingo_main._gui_bingo_board.get_ball_position(from_space_index)
	var to_position:Vector2 = _gui_bingo_main._gui_bingo_board.get_ball_position(board_index)
	await _animation_symbol_move(ball_data, from_position, to_position, 1.0, time)

func display_power_ball(_ball_data:BingoBallData, _board_index:int) -> void:
	pass

func animate_remove_balls_from_board(indexes:Array, with_audio:bool = true, time:float = 0.3) -> void:
	_removal_count = indexes.size()
	for index in indexes:
		var gui_space:GUIBingoSpace = _gui_bingo_main._gui_bingo_board.get_space(index)
		gui_space.remove_animation_finished.connect(_on_remove_animation_finished.bind(gui_space))
		gui_space.animate_removal(with_audio, time)

func animate_move_balls(from_indexes:Array, to_indexes:Array, time:float = 0.3) -> void:
	_move_count = from_indexes.size()
	for i in from_indexes.size():
		var from_index:int = from_indexes[i]
		var to_index:int = to_indexes[i]
		var ball_data:BingoBallData = _gui_bingo_main._gui_bingo_board.get_space(from_index)._space_data.ball_data
		var gui_space:GUIBingoSpace = _gui_bingo_main._gui_bingo_board.get_space(from_index)
		gui_space.move_animation_finished.connect(_on_move_animation_finished.bind(gui_space, ball_data, to_index))
		gui_space.animate_move_to_space(self, to_index, time)

func _animation_symbol_move(ball_data:BingoBallData, from_position:Vector2, to_position:Vector2, starting_scale:float = 1.0, time:float = 0.3) -> void:
	var gui_symbol:GUISymbol = GUI_SYMBOL_SCENE.instantiate()
	add_child(gui_symbol)
	gui_symbol.bind_ball_data(ball_data)
	gui_symbol.global_position = from_position
	gui_symbol.scale = Vector2.ONE * starting_scale
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(gui_symbol, "global_position", to_position, time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.set_parallel().tween_property(gui_symbol, "scale", Vector2.ONE, time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	await tween.finished
	gui_symbol.queue_free()

func animate_symbol_attack(space:BingoSpaceData, has_power_up:bool, time:float) -> void:
	var target_position := Vector2.ZERO
	match space.ball_data.team:
		BingoBallData.Team.PLAYER:
			target_position = _gui_bingo_main._gui_enemy_container._gui_enemy_box.get_reference_position()
		BingoBallData.Team.ENEMY:
			target_position = _gui_bingo_main._gui_player_box.get_reference_position()
	await _gui_bingo_main._gui_bingo_board.get_space(space.index).animate_attack(self, has_power_up, target_position, time)

func animate_enemy_died() -> void:
	var _enemy_box:GUIEnemyBox = _gui_bingo_main._enemy_box
	await _enemy_box.animate_death()

func _get_gui_bingo_main() -> GUIBingoMain:
	return _weak_gui_bingo_main.get_ref()

#region events

func _on_remove_animation_finished(gui_space:GUIBingoSpace) -> void:
	gui_space.remove_animation_finished.disconnect(_on_remove_animation_finished.bind(gui_space))
	_removal_count -= 1
	assert(_removal_count >= 0, "removal_count is negative")
	if _removal_count == 0:
		removal_animation_finished.emit()

func _on_move_animation_finished(gui_space:GUIBingoSpace, ball_data:BingoBallData, to_index:int) -> void:
	gui_space.move_animation_finished.disconnect(_on_move_animation_finished.bind(gui_space, ball_data, to_index))
	_gui_bingo_main._gui_bingo_board.display_ball(ball_data, to_index)
	_move_count -= 1
	assert(_move_count >= 0, "move_count is negative")
	if _move_count == 0:
		move_animation_finished.emit()

#endregion
