extends GutTest

# ----- Stubs -----

class FakePlant extends Plant:
	func apply_actions(_actions: Array, _combat_main: CombatMain) -> void:
		pass

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket(turn: int = 6) -> PlayerTrinketRainbowEgg:
	var t := PlayerTrinketRainbowEgg.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"water"] = "2"
	td.data[&"light"] = "2"
	td.data[&"turn"] = str(turn)
	t.data = td
	return t

# ----- has_start_turn_hook -----

func test_has_hook_true_on_configured_turn() -> void:
	var t := _make_trinket(6)
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 5
	assert_true(t.has_start_turn_hook(cm))

func test_has_hook_false_before_configured_turn() -> void:
	var t := _make_trinket(6)
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	assert_false(t.has_start_turn_hook(cm))

func test_has_hook_false_after_configured_turn() -> void:
	var t := _make_trinket(6)
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 6
	assert_false(t.has_start_turn_hook(cm))

func test_hook_respects_different_configured_turn() -> void:
	var t := _make_trinket(3)
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 2
	assert_true(t.has_start_turn_hook(cm))

# ----- handle_start_turn_hook (ACTIVE during hook, NORMAL after) -----

func test_handle_start_turn_hook_ends_in_normal_state() -> void:
	var t := _make_trinket(6)
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 5
	var pfc := PlantFieldContainer.new()
	autofree(pfc)
	var fp := FakePlant.new()
	autofree(fp)
	pfc.plants.append(fp)
	cm.plant_field_container = pfc
	await t._handle_start_turn_hook(cm)
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)
	assert_true(saw_anim[0])

# ----- other hooks absent -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
