extends GutTest

# ----- has_discard_hook -----

func test_has_discard_hook_returns_true() -> void:
	var s := PlayerStatusMulch.new()
	add_child_autofree(s)
	assert_true(s.has_discard_hook(null, []))

func test_has_discard_hook_true_with_cards() -> void:
	var s := PlayerStatusMulch.new()
	add_child_autofree(s)
	assert_true(s.has_discard_hook(null, [ToolData.new(), ToolData.new()]))
