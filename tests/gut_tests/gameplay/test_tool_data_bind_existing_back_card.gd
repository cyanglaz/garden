extends GutTest


func _simulate_update_tool_card_copy(tool_data: ToolData, new_tool_data: ToolData) -> void:
	if tool_data != new_tool_data:
		tool_data.copy(new_tool_data)


func test_bind_existing_back_card_keeps_same_reference() -> void:
	var front := ToolData.new()
	var back := ToolData.new()
	front.id = "test_front_bind"
	back.id = "test_back_bind"
	autofree(front)
	autofree(back)
	front.bind_existing_back_card(back)
	assert_eq(front.back_card, back)


func test_bind_existing_back_card_wires_front_card_weak_ref() -> void:
	var front := ToolData.new()
	var back := ToolData.new()
	front.id = "test_front_wire"
	back.id = "test_back_wire"
	autofree(front)
	autofree(back)
	front.bind_existing_back_card(back)
	assert_eq(back.front_card, front)


func test_bind_existing_back_card_null_clears_back() -> void:
	var front := ToolData.new()
	var back := ToolData.new()
	autofree(front)
	autofree(back)
	front.bind_existing_back_card(back)
	front.bind_existing_back_card(null)
	assert_null(front.back_card)


func test_same_reference_skips_copy_preserves_actions() -> void:
	var td := ToolData.new()
	var action := ActionData.new()
	action.type = ActionData.ActionType.ENERGY
	action.value = 3
	td.actions.append(action)
	autofree(td)
	_simulate_update_tool_card_copy(td, td)
	assert_eq(td.actions.size(), 1)
	assert_eq(td.actions[0].value, 3)


func test_distinct_reference_copy_still_runs() -> void:
	var into := ToolData.new()
	var from := ToolData.new()
	var a1 := ActionData.new()
	a1.type = ActionData.ActionType.ENERGY
	a1.value = 7
	from.actions.append(a1)
	from.id = "from_id"
	autofree(into)
	autofree(from)
	_simulate_update_tool_card_copy(into, from)
	assert_eq(into.id, "from_id")
	assert_eq(into.actions.size(), 1)
	assert_eq(into.actions[0].value, 7)
