extends GutTest

# ----- Stubs -----

class FakePlant:
	var last_actions: Array = []
	func apply_actions(actions: Array) -> void:
		last_actions = actions

# ----- Helpers -----

func _make_status(value: int, stack_count: int) -> PlayerRefraction:
	var s := add_child_autofree(PlayerRefraction.new())
	var sd := StatusData.new()
	sd.data["value"] = value
	s.data = sd
	s.stack = stack_count
	return s

# ----- has_target_plant_water_update_hook -----

func test_has_hook_true_for_positive_diff() -> void:
	var s := add_child_autofree(PlayerRefraction.new())
	assert_true(s.has_target_plant_water_update_hook(null, null, 1))

func test_has_hook_false_for_zero_diff() -> void:
	var s := add_child_autofree(PlayerRefraction.new())
	assert_false(s.has_target_plant_water_update_hook(null, null, 0))

func test_has_hook_false_for_negative_diff() -> void:
	var s := add_child_autofree(PlayerRefraction.new())
	assert_false(s.has_target_plant_water_update_hook(null, null, -1))

# ----- handle_target_plant_water_update_hook -----

func test_handle_applies_light_increase() -> void:
	var s := _make_status(4, 2)
	var plant := FakePlant.new()
	await s.handle_target_plant_water_update_hook(null, plant, 1)
	assert_eq(plant.last_actions[0].type, ActionData.ActionType.LIGHT)
	assert_eq(plant.last_actions[0].operator_type, ActionData.OperatorType.INCREASE)

func test_handle_light_value_is_stack_times_data_value() -> void:
	var s := _make_status(4, 2)
	var plant := FakePlant.new()
	await s.handle_target_plant_water_update_hook(null, plant, 1)
	assert_eq(plant.last_actions[0].value, 8)
