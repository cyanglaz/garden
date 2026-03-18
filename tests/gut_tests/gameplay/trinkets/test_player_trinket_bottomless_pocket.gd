extends GutTest

# ----- Stubs -----

class FakeToolManager extends ToolManager:
	func _init() -> void:
		tool_deck = Deck.new([])

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

func _make_combat_main_with_hand(hand_items:Array) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	var tm := FakeToolManager.new()
	tm.tool_deck.hand.assign(hand_items)
	cm.tool_manager = tm
	return cm

# ----- has_hand_updated_hook -----

func test_has_hand_updated_hook_true_when_hand_empty() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main_with_hand([])
	assert_true(t.has_hand_updated_hook(cm))

func test_has_hand_updated_hook_false_when_hand_has_cards() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main_with_hand([ToolData.new()])
	assert_false(t.has_hand_updated_hook(cm))

# ----- other hooks absent -----

func test_has_no_discard_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_discard_hook(null, []))

func test_has_no_exhaust_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_exhaust_hook(null, []))

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
