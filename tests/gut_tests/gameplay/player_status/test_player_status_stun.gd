extends GutTest

# ----- has_prevent_movement_hook -----

func test_has_prevent_movement_hook() -> void:
	var s := PlayerStatusStun.new()
	add_child_autofree(s)
	assert_true(s.has_prevent_movement_hook())
