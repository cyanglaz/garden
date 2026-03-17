extends GutTest

# Note: _handle_tool_application_hook iterates plants with a typed `for plant:Plant`
# loop and awaits an internal signal — this requires a live scene with real Plant
# nodes and is not suitable for isolation testing. Only the predicate is tested here.

# ----- Helpers -----

func _make_tool(energy_cost: int) -> ToolData:
	var td := ToolData.new()
	td.energy_cost = energy_cost
	return td

# ----- has_tool_application_hook -----

func test_has_hook_true_for_zero_energy_cost() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	assert_true(s.has_tool_application_hook(null, _make_tool(0)))

func test_has_hook_false_for_nonzero_energy_cost() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	assert_false(s.has_tool_application_hook(null, _make_tool(1)))

func test_has_hook_false_for_high_energy_cost() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	assert_false(s.has_tool_application_hook(null, _make_tool(5)))
