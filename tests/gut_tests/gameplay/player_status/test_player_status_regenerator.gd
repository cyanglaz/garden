extends GutTest

# ----- has_stack_update_hook -----

func test_has_hook_true_for_momentum_negative_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_true(s.has_stack_update_hook(null, "momentum", -1))

func test_has_hook_false_for_momentum_zero_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "momentum", 0))

func test_has_hook_false_for_momentum_positive_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "momentum", 1))

func test_has_hook_false_for_other_status_negative_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "water", -1))
