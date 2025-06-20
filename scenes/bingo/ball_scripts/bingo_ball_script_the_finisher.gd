class_name BingoBallScriptTheFinisher
extends BingoBallScript

var _formed_bingo:bool = false

func _has_placement_events() -> bool:
	return _check_formed_bingo()

func _handle_placement_events() -> void:
	_formed_bingo = _check_formed_bingo()
	_placed_on_board_event_finished.emit()

func _enhance_attack(bingo_result:BingoResult, attack:Attack) -> void:
	if has_power_up(bingo_result):
		attack.additional_damage += _bingo_ball_data.data["dmg"] as int

func _has_power_up(_bingo_result:BingoResult) -> bool:
	return _formed_bingo

func evaluate_for_description() -> void:
	if _has_power_up(null):
		_bingo_ball_data.highlight_description_keys["dmg"] = true
		_bingo_ball_data.highlight_description_keys["corner"] = true
	else:
		_bingo_ball_data.highlight_description_keys["dmg"] = false
		_bingo_ball_data.highlight_description_keys["corner"] = false

func _check_formed_bingo() -> bool:
	var bingo_results:Array[BingoResult] = bingo_board.check_bingo()
	var formed_bingo:bool = false
	for result:BingoResult in bingo_results:
		for space:BingoSpaceData in result.spaces:
			if space.index == bingo_space_data.index:
				formed_bingo = true
				break
	return formed_bingo
