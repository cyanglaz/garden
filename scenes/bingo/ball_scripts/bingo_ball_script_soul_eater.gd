class_name BingoBallScriptSoulEater
extends BingoBallScript

func _has_placement_events() -> bool:
	var removing_balls:Array = _get_enemy_balls()
	if removing_balls.size() > 0:
		return true
	return false

func _get_enemy_balls() -> Array:
	var row := BingoBoard.find_row(bingo_space_data.index)
	var removing_balls :Array= bingo_board.board.filter(func(space:BingoSpaceData) -> bool:
		return space.ball_data && space.ball_data.team == BingoBallData.Team.ENEMY && BingoBoard.find_row(space.index) == row
	)
	return removing_balls.map(func(space:BingoSpaceData) -> int: return space.index)

func _handle_placement_events() -> void:
	var removing_balls:Array = _get_enemy_balls()
	Singletons.game_main._bingo_controller.remove_ball_operation_finished.connect(_on_remove_ball_operation_finished.bind(Singletons.game_main._bingo_controller, removing_balls.size()))
	Singletons.game_main._bingo_controller.handle_remove_balls_from_board(removing_balls)
	_placed_on_board_event_finished.emit()

func _update_self(num_removed:int) -> void:
	var dmg_boost := num_removed * (_bingo_ball_data.data["dmg"] as int)
	if dmg_boost > 0:
		_bingo_ball_data.combat_dmg_boost += dmg_boost
		_bingo_ball_data.data["total"] = str("(",dmg_boost,")")
		_bingo_ball_data.highlight_description_keys["dmg"] = true
		_bingo_ball_data.highlight_description_keys["total"] = true
	else:
		_bingo_ball_data.data["total"] = ""
		_bingo_ball_data.highlight_description_keys["dmg"] = false
		_bingo_ball_data.highlight_description_keys["total"] = false


func _on_remove_ball_operation_finished(bingo_controller:BingoController, number_removed:int) -> void:
	bingo_controller.remove_ball_operation_finished.disconnect(_on_remove_ball_operation_finished)
	_update_self(number_removed)
	_placed_on_board_event_finished.emit()
