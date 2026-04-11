extends GutTest

# ----- Stubs -----

class FakePlantForShard extends Plant:
	func apply_actions(_actions: Array, _combat_main: CombatMain) -> void:
		pass

class FakePlantFieldForShard extends PlantFieldContainer:
	var plant_at_field: Plant = null
	func get_plant(_index: int) -> Plant:
		return plant_at_field

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket(light_value: int = 3) -> PlayerTrinketSunShard:
	var t := PlayerTrinketSunShard.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data["light"] = light_value
	t.data = td
	return t

func _make_combat_main(field_index: int, max_idx: int) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	var psc := PlayerStatusContainer.new()
	autofree(psc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = psc
	p.max_plants_index = max_idx
	p.current_field_index = field_index
	cm.player = p
	return cm

# ----- has_end_turn_hook -----

func test_has_hook_true_at_index_zero() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0, 3)
	assert_true(t.has_end_turn_hook(cm))

func test_has_hook_true_at_max_index() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(3, 3)
	assert_true(t.has_end_turn_hook(cm))

func test_has_hook_false_at_middle_index() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(1, 3)
	assert_false(t.has_end_turn_hook(cm))

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

func test_handle_end_turn_hook_emits_hook_animation_signal() -> void:
	var t := _make_trinket()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := _make_combat_main(0, 3)
	var pfc := FakePlantFieldForShard.new()
	autofree(pfc)
	var fp := FakePlantForShard.new()
	autofree(fp)
	pfc.plant_at_field = fp
	cm.plant_field_container = pfc
	await t._handle_end_turn_hook(cm)
	assert_true(saw_anim[0])

