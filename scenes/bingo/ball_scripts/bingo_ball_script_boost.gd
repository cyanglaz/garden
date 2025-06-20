class_name BingoBallScriptBoost
extends BingoBallScript

func _has_other_symbol_placement_events(displayed_space:BingoSpaceData) -> bool:
	var has_balls_to_draw := Singletons.game_main._player.draw_box.draw_pool.size() + Singletons.game_main._player.draw_box.discard_pool.size() > 0
	return BingoBoard.find_row(displayed_space.index) == BingoBoard.find_row(bingo_space_data.index) && has_balls_to_draw

func _handle_other_symbol_replacement_events() -> void:
	await Singletons.game_main._bingo_controller.start_other_draw(_bingo_ball_data.data["card"] as int)
	_other_symbol_replacement_event_finished.emit()
