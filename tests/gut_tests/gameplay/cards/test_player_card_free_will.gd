extends GutTest


class FakeCombatMain extends CombatMain:
	func _init():
		pass


func _make_tool_data() -> ToolData:
	var td := ToolData.new()
	autofree(td)
	return td


func _make_combat_main() -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	return cm

func test_number_of_secondary_cards_to_select_is_one() -> void:
	assert_eq(ToolScriptFreeWill.new().number_of_secondary_cards_to_select(), 1)

func test_get_card_selection_type_is_non_restricted() -> void:
	assert_eq(ToolScriptFreeWill.new().get_card_selection_type(), ActionData.CardSelectionType.NON_RESTRICTED)

func test_apply_tool_adds_reversible_to_selected_card() -> void:
	var selected := _make_tool_data()
	var cm := _make_combat_main()
	await ToolScriptFreeWill.new().apply_tool(cm, null, [selected])
	assert_true(selected.specials.has(ToolData.Special.REVERSIBLE))

func test_apply_tool_does_not_duplicate_reversible_on_front() -> void:
	var selected := _make_tool_data()
	selected.specials.append(ToolData.Special.REVERSIBLE)
	var cm := _make_combat_main()
	await ToolScriptFreeWill.new().apply_tool(cm, null, [selected])
	var count := selected.specials.filter(func(s): return s == ToolData.Special.REVERSIBLE).size()
	assert_eq(count, 1)
