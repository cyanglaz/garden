extends GutTest

class FakePlant extends Plant:
	func apply_actions(_actions: Array) -> void:
		pass

class FakePlantFieldForTrinket extends PlantFieldContainer:
	var plant_at_field: Plant = null
	func get_plant(_index: int) -> Plant:
		return plant_at_field

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket(pest: int = 2, fungus: int = 1) -> PlayerTrinketSaltGrinder:
	var t := PlayerTrinketSaltGrinder.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data["pest"] = pest
	td.data["fungus"] = fungus
	t.data = td
	return t

# ----- has_*_hook -----

func test_has_start_turn_hook_returns_true() -> void:
	var t := PlayerTrinketSaltGrinder.new()
	add_child_autofree(t)
	assert_true(t.has_start_turn_hook(null))

func test_handle_start_turn_hook_emits_hook_animation_signal() -> void:
	var t := _make_trinket()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := FakeCombatMain.new()
	autofree(cm)
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

func test_has_no_end_turn_hook() -> void:
	var t := PlayerTrinketSaltGrinder.new()
	add_child_autofree(t)
	assert_false(t.has_end_turn_hook(null))
