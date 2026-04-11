extends GutTest

const PLAYER_SCENE := preload("res://scenes/main_game/combat/player/player.tscn")

class FakeFieldStatusContainer extends FieldStatusContainer:
	var pest_stack: int = 0
	var fungus_stack: int = 0
	func get_status_stack(status_id: String) -> int:
		if status_id == "pest":
			return pest_stack
		if status_id == "fungus":
			return fungus_stack
		return 0

class FakePlant extends Plant:
	func apply_actions(_actions: Array) -> void:
		pass

class FakePlantFieldContainer extends PlantFieldContainer:
	var plant_at_field: Plant = null
	func get_plant(_index: int) -> Plant:
		return plant_at_field

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketGuardiansBadge:
	var t := PlayerTrinketGuardiansBadge.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"light"] = "1"
	td.data[&"water"] = "1"
	t.data = td
	return t

func _make_combat_main_with_plants(plant_list: Array) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	var pfc := FakePlantFieldContainer.new()
	autofree(pfc)
	for p in plant_list:
		pfc.plants.append(p)
	if plant_list.size() > 0:
		pfc.plant_at_field = plant_list[0]
	var player: Player = PLAYER_SCENE.instantiate()
	add_child_autofree(player)
	player.max_plants_index = 3
	player.current_field_index = 0
	cm.player = player
	cm.plant_field_container = pfc
	return cm

# ----- has_end_turn_hook -----

func test_has_end_turn_hook_true_when_no_plants() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main_with_plants([])
	assert_true(t.has_end_turn_hook(cm))

func test_has_end_turn_hook_true_when_plants_clean() -> void:
	var t := _make_trinket()
	var fp := FakePlant.new()
	autofree(fp)
	var fsc := FakeFieldStatusContainer.new()
	autofree(fsc)
	fp.field_status_container = fsc
	var cm := _make_combat_main_with_plants([fp])
	assert_true(t.has_end_turn_hook(cm))

func test_has_end_turn_hook_false_when_plant_has_pest() -> void:
	var t := _make_trinket()
	var fp := FakePlant.new()
	autofree(fp)
	var fsc := FakeFieldStatusContainer.new()
	autofree(fsc)
	fsc.pest_stack = 1
	fp.field_status_container = fsc
	var cm := _make_combat_main_with_plants([fp])
	assert_false(t.has_end_turn_hook(cm))

func test_has_end_turn_hook_false_when_plant_has_fungus() -> void:
	var t := _make_trinket()
	var fp := FakePlant.new()
	autofree(fp)
	var fsc := FakeFieldStatusContainer.new()
	autofree(fsc)
	fsc.fungus_stack = 2
	fp.field_status_container = fsc
	var cm := _make_combat_main_with_plants([fp])
	assert_false(t.has_end_turn_hook(cm))

# ----- _handle_end_turn_hook -----

func test_handle_end_turn_hook_emits_animation_signal() -> void:
	var t := _make_trinket()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var fp := FakePlant.new()
	autofree(fp)
	var cm := _make_combat_main_with_plants([fp])
	await t._handle_end_turn_hook(cm)
	assert_true(saw_anim[0])

# ----- absent hooks -----

func test_has_no_start_turn_hook() -> void:
	assert_false(_make_trinket().has_start_turn_hook(null))

func test_has_no_draw_hook() -> void:
	assert_false(_make_trinket().has_draw_hook(null, []))

func test_has_no_discard_hook() -> void:
	assert_false(_make_trinket().has_discard_hook(null, []))

func test_has_no_exhaust_hook() -> void:
	assert_false(_make_trinket().has_exhaust_hook(null, []))
