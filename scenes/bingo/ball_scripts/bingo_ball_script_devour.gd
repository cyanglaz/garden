class_name BingoBallScriptDevour
extends BingoBallScript

var _devoured_count := 0

func _has_draw_events(draws:int) -> bool:
	return draws % (_bingo_ball_data.data["draw"] as int) == 0

func _enhance_attack(bingo_result:BingoResult, attack:Attack) -> void:
	if has_power_up(bingo_result):
		attack.additional_damage += (_bingo_ball_data.data["dmg"] as int) * _devoured_count

func _has_power_up(_bingo_result:BingoResult) -> bool:
	return _devoured_count > 0

func evaluate_for_description() -> void:
	_bingo_ball_data.data["total"] = "(" + str(_devoured_count * (_bingo_ball_data.data["dmg"] as int)) + ")"
	if _devoured_count > 0:
		_bingo_ball_data.highlight_description_keys["total"] = true
	else:
		_bingo_ball_data.highlight_description_keys["total"] = false

func _on_remove_ball_operation_finished(bingo_controller:BingoController) -> void:
	bingo_controller.remove_ball_operation_finished.disconnect(_on_remove_ball_operation_finished)
	_draw_event_finished.emit()

func _handle_draw_events() -> void:
	_devoured_count += 1
	var spaces_with_data := bingo_board.board.filter(func(space_data:BingoSpaceData) -> bool:
		return space_data.ball_data != null && space_data.index != bingo_space_data.index
	)
	spaces_with_data.shuffle()
	var random_space:BingoSpaceData = spaces_with_data.back()
	Singletons.game_main._bingo_controller.remove_ball_operation_finished.connect(_on_remove_ball_operation_finished.bind(Singletons.game_main._bingo_controller))
	Singletons.game_main._bingo_controller.handle_remove_balls_from_board([random_space.index])
