extends GutTest

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketNectarRefresher:
	var t := PlayerTrinketNectarRefresher.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"momentum"] = "3"
	t.data = td
	return t

# ----- has_start_turn_hook -----

func test_has_hook_true_on_turn_3() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 2
	assert_true(t.has_start_turn_hook(cm))

func test_has_hook_false_on_other_turn() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	assert_false(t.has_start_turn_hook(cm))

func test_handle_start_turn_hook_emits_hook_animation_signal() -> void:
	var t := _make_trinket()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 2
	var psc := PlayerStatusContainer.new()
	autofree(psc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = psc
	cm.player = p
	t._handle_start_turn_hook(cm)
	assert_true(saw_anim[0])

# ----- has_end_turn_hook -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
