extends GutTest

# Note: _handle_draw_hook creates a PlayerActionApplier and calls into the
# Events/CombatMain system — this requires a live scene and is not suitable
# for isolation testing. Only the predicate is tested here.

# ----- has_draw_hook -----

func test_has_draw_hook_returns_true() -> void:
	var s := add_child_autofree(PlayerStatusOverclock.new())
	assert_true(s.has_draw_hook(null, []))

func test_has_draw_hook_true_with_non_empty_array() -> void:
	var s := add_child_autofree(PlayerStatusOverclock.new())
	var td := ToolData.new()
	assert_true(s.has_draw_hook(null, [td]))
