extends GutTest

# ----- Helpers -----

func _make_tool(energy_cost: int) -> ToolData:
	var td := ToolData.new()
	td.energy_cost = energy_cost
	return td

# ----- has_tool_application_hook -----

func test_has_hook_true_for_zero_energy_cost() -> void:
	var s := PlayerStatusCleanEnergy.new()
	add_child_autofree(s)
	assert_true(s.has_tool_application_hook(null, _make_tool(0)))

func test_has_hook_false_for_nonzero_energy_cost() -> void:
	var s := PlayerStatusCleanEnergy.new()
	add_child_autofree(s)
	assert_false(s.has_tool_application_hook(null, _make_tool(1)))

func test_has_hook_true_when_turn_modifier_makes_final_cost_zero() -> void:
	var s := PlayerStatusCleanEnergy.new()
	add_child_autofree(s)
	var tool := _make_tool(2)
	tool.turn_energy_modifier = -2
	assert_true(s.has_tool_application_hook(null, tool))

func test_has_hook_true_when_level_modifier_makes_final_cost_zero() -> void:
	var s := PlayerStatusCleanEnergy.new()
	add_child_autofree(s)
	var tool := _make_tool(2)
	tool.level_energy_modifier = -2
	assert_true(s.has_tool_application_hook(null, tool))

func test_has_hook_false_for_high_energy_cost() -> void:
	var s := PlayerStatusCleanEnergy.new()
	add_child_autofree(s)
	assert_false(s.has_tool_application_hook(null, _make_tool(5)))
