extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketBountyJar:
	var t := PlayerTrinketBountyJar.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"gold"] = "3"
	t.data = td
	return t

func _make_tool_data_with_pest_decrease() -> ToolData:
	var td := ToolData.new()
	var action := ActionData.new()
	action.type = ActionData.ActionType.PEST
	action.operator_type = ActionData.OperatorType.DECREASE
	action.value = 1
	td.actions.append(action)
	return td

func _make_tool_data_with_pest_increase() -> ToolData:
	var td := ToolData.new()
	var action := ActionData.new()
	action.type = ActionData.ActionType.PEST
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = 1
	td.actions.append(action)
	return td

func _make_tool_data_no_pest() -> ToolData:
	var td := ToolData.new()
	var action := ActionData.new()
	action.type = ActionData.ActionType.WATER
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = 1
	td.actions.append(action)
	return td

# ----- _has_pest_decrease_action helper -----

func test_pest_decrease_detected() -> void:
	var t := _make_trinket()
	assert_true(t._has_pest_decrease_action(_make_tool_data_with_pest_decrease()))

func test_pest_increase_not_detected() -> void:
	var t := _make_trinket()
	assert_false(t._has_pest_decrease_action(_make_tool_data_with_pest_increase()))

func test_no_pest_action_not_detected() -> void:
	var t := _make_trinket()
	assert_false(t._has_pest_decrease_action(_make_tool_data_no_pest()))

func test_null_tool_data_not_detected() -> void:
	var t := _make_trinket()
	assert_false(t._has_pest_decrease_action(null))

# ----- other hooks absent -----

func test_has_no_tool_application_hook() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	assert_false(t.has_tool_application_hook(cm, null))

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))

func test_has_no_draw_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_draw_hook(null, []))

func test_has_no_discard_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_discard_hook(null, []))
