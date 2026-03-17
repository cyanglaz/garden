extends GutTest

# ----- has_prevent_movement_hook -----

func test_has_prevent_movement_hook() -> void:
	var s := add_child_autofree(PlayerStatusStun.new())
	assert_true(s.has_prevent_movement_hook())
