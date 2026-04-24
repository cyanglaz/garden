extends GutTest

# ----- Stubs -----

class FakePlayerStatusContainer extends PlayerStatusContainer:
	var _stacks: Dictionary = {}
	func get_player_upgrade_stack(id: String) -> int:
		return _stacks.get(id, 0)
	func set_player_upgrade(id: String, stack: int) -> void:
		_stacks[id] = stack

class FakeCombatMain extends CombatMain:
	pass

# ----- has_start_turn_hook -----

func test_has_hook_true_when_free_move_zero() -> void:
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

func test_has_hook_false_when_free_move_nonzero() -> void:
	var t := PlayerTrinketSpareWing.new()
	add_child_autofree(t)
	var fake_sc := FakePlayerStatusContainer.new()
	autofree(fake_sc)
	fake_sc._stacks["free_move"] = 2
	var p := Player.new()
	autofree(p)
	p.player_status_container = fake_sc
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.player = p
	assert_false(t.has_start_turn_hook(cm))

func test_handle_start_turn_hook_emits_hook_animation_signals() -> void:
	var t := PlayerTrinketSpareWing.new()
	add_child_autofree(t)
	t.data = TrinketData.new()
	t.data.id = "spare_wing"
	var saw_anim: Array = [false]
	var saw_popup: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	t.request_hook_message_popup.connect(func(_td: ThingData) -> void: saw_popup[0] = true)
	var fake_sc := FakePlayerStatusContainer.new()
	autofree(fake_sc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = fake_sc
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.player = p
	t._handle_start_turn_hook(cm)
	assert_true(saw_anim[0])
	assert_true(saw_popup[0])

func test_has_no_end_turn_hook() -> void:
	var t := PlayerTrinketSpareWing.new()
	add_child_autofree(t)
	assert_false(t.has_end_turn_hook(null))
