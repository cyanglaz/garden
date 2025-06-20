class_name BingoBallScriptQuickDraw
extends BingoBallScript

func _has_self_bingo_events(_bingo_result:BingoResult) -> bool:
	var qualified_bows := _get_qualified_bows()
	return !qualified_bows.is_empty()

func _has_self_bingo_event_trigger_animation() -> bool:
	return true

func _handle_self_bingo_events(_bingo_result:BingoResult) -> void:
	var qualified_bows := _get_qualified_bows()
	var random_bow:BingoSpaceData = qualified_bows.pick_random()
	if random_bow:
		var trigger_time := _bingo_ball_data.data["time"] as int
		for i in trigger_time:
			var character_died := await Singletons.game_main._bingo_controller.handle_one_space_bingo(random_bow, null)
			if character_died:
				break
	_self_bingo_event_finished.emit()

func _get_qualified_bows() -> Array:
	var synergy_weapon_ids:Array = _bingo_ball_data.data["bows"]
	var other_bow_spaces := bingo_board.board.filter(func(space:BingoSpaceData) -> bool:
		# The space is a synergy weapon and not in the bingo result
		return space.ball_data && (space.ball_data.base_id in synergy_weapon_ids)
	)
	return other_bow_spaces
