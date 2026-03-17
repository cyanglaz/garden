extends GutTest

const PLANT_SCENE := preload("res://scenes/main_game/plants/plants/plant.tscn")

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_plant(light_max: int = 20, water_max: int = 20) -> Plant:
	var plant: Plant = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	var pd := PlantData.new()
	pd.light = light_max
	pd.water = water_max
	plant.data = pd
	return plant

func _make_trinket(light_value: int = 3) -> PlayerTrinketSunShard:
	var t := PlayerTrinketSunShard.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data["light"] = light_value
	t.data = td
	return t

func _make_combat_main(field_index: int, max_idx: int) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	var p := Player.new()
	p.max_plants_index = max_idx
	p.player_status_container = PlayerStatusContainer.new()
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

# ----- handle_end_turn_hook -----

func test_handle_increases_plant_light_by_data_value() -> void:
	var plant := _make_plant()
	var t := _make_trinket(7)
	var cm := _make_combat_main(0, 3)
	var pfc := PlantFieldContainer.new()
	pfc.plants.append(plant)
	cm.plant_field_container = pfc
	await t.handle_end_turn_hook(cm)
	assert_eq(plant.light.value, 7)
