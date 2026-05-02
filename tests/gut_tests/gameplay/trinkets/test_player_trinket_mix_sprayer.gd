extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketMixSprayer:
	var t := PlayerTrinketMixSprayer.new()
	add_child_autofree(t)
	t.data = TrinketData.new()
	return t

func _make_combat_main(hand: Array) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	var tm := ToolManager.new([], null)
	tm.tool_deck.hand = hand
	cm.tool_manager = tm
	return cm

# ----- has_exhaust_hook -----

func test_has_exhaust_hook_true_when_hand_not_empty() -> void:
	var t := _make_trinket()
	assert_true(t.has_exhaust_hook(_make_combat_main([ToolData.new()]), []))

func test_has_exhaust_hook_false_when_energy_modifier_makes_hand_card_free() -> void:
	var t := _make_trinket()
	var card := ToolData.new()
	card.energy_cost = 2
	card.turn_energy_modifier = -2
	assert_false(t.has_exhaust_hook(_make_combat_main([card]), []))

func test_has_exhaust_hook_true_when_level_modifier_keeps_final_cost_positive() -> void:
	var t := _make_trinket()
	var card := ToolData.new()
	card.energy_cost = 0
	card.level_energy_modifier = 1
	assert_true(t.has_exhaust_hook(_make_combat_main([card]), []))

func test_has_exhaust_hook_false_when_hand_empty() -> void:
	var t := _make_trinket()
	assert_false(t.has_exhaust_hook(_make_combat_main([]), []))

func test_handle_exhaust_hook_emits_hook_animation_signal() -> void:
	var t := _make_trinket()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := _make_combat_main([ToolData.new()])
	t._handle_exhaust_hook(cm, [])
	assert_true(saw_anim[0])

# ----- other hooks absent -----

func test_has_no_start_turn_hook() -> void:
	assert_false(_make_trinket().has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	assert_false(_make_trinket().has_end_turn_hook(null))

func test_has_no_discard_hook() -> void:
	assert_false(_make_trinket().has_discard_hook(null, []))

func test_has_no_draw_hook() -> void:
	assert_false(_make_trinket().has_draw_hook(null, []))
