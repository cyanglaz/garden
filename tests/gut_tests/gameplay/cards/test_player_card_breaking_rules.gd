extends GutTest


class FakeCombatMain extends CombatMain:
	func _init():
		pass


class FakeToolManager extends ToolManager:
	func _init():
		tool_deck = Deck.new([])


func _make_tool_data() -> ToolData:
	var td := ToolData.new()
	autofree(td)
	return td


func _make_combat_main_with_hand(cards: Array) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	var tm := FakeToolManager.new()
	tm.tool_deck.hand = cards
	cm.tool_manager = tm
	autofree(cm)
	return cm


func test_apply_tool_adds_reversible_to_all_hand_cards() -> void:
	var c1 := _make_tool_data()
	var c2 := _make_tool_data()
	var cm := _make_combat_main_with_hand([c1, c2])
	await ToolScriptBreakingRules.new().apply_tool(cm, null, [])
	assert_true(c1.specials.has(ToolData.Special.REVERSIBLE))
	assert_true(c2.specials.has(ToolData.Special.REVERSIBLE))


func test_apply_tool_does_not_duplicate_reversible() -> void:
	var c1 := _make_tool_data()
	c1.specials.append(ToolData.Special.REVERSIBLE)
	var cm := _make_combat_main_with_hand([c1])
	await ToolScriptBreakingRules.new().apply_tool(cm, null, [])
	var count := c1.specials.filter(func(s): return s == ToolData.Special.REVERSIBLE).size()
	assert_eq(count, 1)


func test_apply_tool_works_with_empty_hand() -> void:
	var cm := _make_combat_main_with_hand([])
	await ToolScriptBreakingRules.new().apply_tool(cm, null, [])
	pass
