extends GutTest

# ----- Stubs -----

class FakeToolManager extends ToolManager:
	pass

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketBottomlessPocket:
	var t := PlayerTrinketBottomlessPocket.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"draw"] = "1"
	t.data = td
	return t

# ----- has_start_turn_hook -----

func test_has_hook_true_when_hand_empty() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	var tm := FakeToolManager.new()
	var deck := Deck.new([])
	tm.tool_deck = deck
	cm.tool_manager = tm
	assert_true(t.has_start_turn_hook(cm))

func test_has_hook_false_when_hand_has_cards() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	var tm := FakeToolManager.new()
	var deck := Deck.new([])
	deck.hand.append("mock_card")
	tm.tool_deck = deck
	cm.tool_manager = tm
	assert_false(t.has_start_turn_hook(cm))

# ----- has_end_turn_hook -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
