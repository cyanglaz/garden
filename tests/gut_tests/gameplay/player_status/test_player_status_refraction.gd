extends GutTest

# ----- has_target_plant_water_update_hook -----

func test_has_hook_true_for_positive_diff() -> void:
	var s := PlayerRefraction.new()
	add_child_autofree(s)
	assert_true(s.has_target_plant_water_update_hook(null, null, 1))

func test_has_hook_false_for_zero_diff() -> void:
	var s := PlayerRefraction.new()
	add_child_autofree(s)
	assert_false(s.has_target_plant_water_update_hook(null, null, 0))

func test_has_hook_false_for_negative_diff() -> void:
	var s := PlayerRefraction.new()
	add_child_autofree(s)
	assert_false(s.has_target_plant_water_update_hook(null, null, -1))
