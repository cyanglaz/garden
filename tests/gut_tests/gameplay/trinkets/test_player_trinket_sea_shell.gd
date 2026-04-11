extends GutTest

# ----- Stubs -----

class FakePlant extends Plant:
	func apply_actions(_actions: Array, _combat_main: CombatMain) -> void:
		pass

class FakePlantFieldForTrinket extends PlantFieldContainer:
	var plant_at_field: Plant = null
	func get_plant(_index: int) -> Plant:
		return plant_at_field

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketSeaShell:
	var t := PlayerTrinketSeaShell.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"water"] = "2"
	t.data = td
	return t

# ----- has_start_turn_hook -----

func test_has_hook_true_on_turn_1() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	assert_true(t.has_start_turn_hook(cm))

func test_has_hook_false_after_turn_1() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 1
	assert_false(t.has_start_turn_hook(cm))

func test_handle_start_turn_hook_emits_hook_animation_signal() -> void:
	var t := _make_trinket()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	var pfc := FakePlantFieldForTrinket.new()
	autofree(pfc)
	var fp := FakePlant.new()
	autofree(fp)
	pfc.plant_at_field = fp
	cm.plant_field_container = pfc
	var p := Player.new()
	autofree(p)
	var psc := PlayerStatusContainer.new()
	autofree(psc)
	p.player_status_container = psc
	p.max_plants_index = 3
	p.current_field_index = 0
	cm.player = p
	await t._handle_start_turn_hook(cm)
	assert_true(saw_anim[0])

# ----- has_end_turn_hook -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
