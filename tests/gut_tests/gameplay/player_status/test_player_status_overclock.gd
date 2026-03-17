extends GutTest

# ----- has_draw_hook -----

func test_has_draw_hook_returns_true() -> void:
	var s := PlayerStatusOverclock.new()
	add_child_autofree(s)
	assert_true(s.has_draw_hook(null, []))

func test_has_draw_hook_true_with_non_empty_array() -> void:
	var s := PlayerStatusOverclock.new()
	add_child_autofree(s)
	assert_true(s.has_draw_hook(null, [ToolData.new()]))
