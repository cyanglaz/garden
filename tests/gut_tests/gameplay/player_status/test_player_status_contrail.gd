extends GutTest

# ----- has_player_move_hook -----

func test_has_player_move_hook_returns_true() -> void:
	var s := PlayerStatusContrail.new()
	add_child_autofree(s)
	assert_true(s.has_player_move_hook(null))
