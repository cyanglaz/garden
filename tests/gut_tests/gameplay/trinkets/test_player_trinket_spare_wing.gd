extends GutTest

# ----- Stubs -----

class FakePlayerStatusContainer extends PlayerStatusContainer:
	var _stacks: Dictionary = {}
	func get_player_upgrade_stack(id: String) -> int:
		return _stacks.get(id, 0)

class FakeCombatMain extends CombatMain:
	pass

# ----- has_start_turn_hook -----

func test_has_hook_true_when_momentum_zero() -> void:
	var t := PlayerTrinketSpareWing.new()
	add_child_autofree(t)
	var fake_sc := FakePlayerStatusContainer.new()
	autofree(fake_sc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = fake_sc
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.player = p
	assert_true(t.has_start_turn_hook(cm))

func test_has_hook_false_when_momentum_nonzero() -> void:
	var t := PlayerTrinketSpareWing.new()
	add_child_autofree(t)
	var fake_sc := FakePlayerStatusContainer.new()
	autofree(fake_sc)
	fake_sc._stacks["momentum"] = 2
	var p := Player.new()
	autofree(p)
	p.player_status_container = fake_sc
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.player = p
	assert_false(t.has_start_turn_hook(cm))

func test_has_no_end_turn_hook() -> void:
	var t := PlayerTrinketSpareWing.new()
	add_child_autofree(t)
	assert_false(t.has_end_turn_hook(null))
