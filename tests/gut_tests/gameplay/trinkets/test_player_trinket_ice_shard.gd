extends GutTest

const PLANT_SCENE := preload("res://scenes/main_game/plants/plants/plant.tscn")

# ----- Stubs -----

class FakePlantFieldContainer:
	var _plant: Plant
	func get_plant(_index: int) -> Plant:
		return _plant

class FakePlayer:
	var current_field_index: int = 0

class FakeCombatMain:
	var player := FakePlayer.new()
	var plant_field_container := FakePlantFieldContainer.new()

# ----- Helpers -----

func _make_plant(light_max: int = 20, water_max: int = 20) -> Plant:
	var plant: Plant = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	var pd := PlantData.new()
	pd.light = light_max
	pd.water = water_max
	plant.data = pd
	return plant

func _make_trinket(water_value: int = 3) -> PlayerTrinketIceShard:
	var t := add_child_autofree(PlayerTrinketIceShard.new())
	var td := TrinketData.new()
	td.data["water"] = water_value
	t.data = td
	return t

# ----- has_end_turn_hook -----

func test_has_end_turn_hook_returns_true() -> void:
	var t := add_child_autofree(PlayerTrinketIceShard.new())
	assert_true(t.has_end_turn_hook(null))

func test_has_no_start_turn_hook() -> void:
	var t := add_child_autofree(PlayerTrinketIceShard.new())
	assert_false(t.has_start_turn_hook(null))

# ----- handle_end_turn_hook -----

func test_handle_increases_plant_water_by_data_value() -> void:
	var plant := _make_plant()
	var t := _make_trinket(6)
	var cm := FakeCombatMain.new()
	cm.plant_field_container._plant = plant
	await t.handle_end_turn_hook(cm)
	assert_eq(plant.water.value, 6)
