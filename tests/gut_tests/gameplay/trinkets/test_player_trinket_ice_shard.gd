extends GutTest

class FakePlantForIce extends Plant:
	func apply_actions(_actions: Array, _combat_main: CombatMain) -> void:
		pass

class FakePlantFieldForIce extends PlantFieldContainer:
	var plant_at_field: Plant = null
	func get_plant(_index: int) -> Plant:
		return plant_at_field

class FakeCombatMain extends CombatMain:
	pass


# ----- Helpers -----

func _make_trinket(water_value: int = 3) -> PlayerTrinketIceShard:
	var t := PlayerTrinketIceShard.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data["water"] = water_value
	t.data = td
	return t

# ----- has_end_turn_hook -----

func test_has_end_turn_hook_returns_true() -> void:
	var t := PlayerTrinketIceShard.new()
	add_child_autofree(t)
	assert_true(t.has_end_turn_hook(null))

func test_has_no_start_turn_hook() -> void:
	var t := PlayerTrinketIceShard.new()
	add_child_autofree(t)
	assert_false(t.has_start_turn_hook(null))

func test_handle_end_turn_hook_emits_hook_animation_signal() -> void:
	var t := _make_trinket()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := FakeCombatMain.new()
	autofree(cm)
	var p := Player.new()
	autofree(p)
	var psc := PlayerStatusContainer.new()
	autofree(psc)
	p.player_status_container = psc
	p.max_plants_index = 3
	p.current_field_index = 0
	cm.player = p
	var pfc := FakePlantFieldForIce.new()
	autofree(pfc)
	var fp := FakePlantForIce.new()
	autofree(fp)
	pfc.plant_at_field = fp
	cm.plant_field_container = pfc
	await t._handle_end_turn_hook(cm)
	assert_true(saw_anim[0])
