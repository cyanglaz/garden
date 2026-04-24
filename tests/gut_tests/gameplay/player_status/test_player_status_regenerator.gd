extends GutTest

# ----- has_stack_update_hook -----

func test_has_hook_true_for_free_move_negative_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_true(s.has_stack_update_hook(null, "free_move", -1))

func test_has_hook_false_for_free_move_zero_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "free_move", 0))

func test_has_hook_false_for_free_move_positive_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "free_move", 1))

func test_has_hook_false_for_other_status_negative_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "water", -1))
