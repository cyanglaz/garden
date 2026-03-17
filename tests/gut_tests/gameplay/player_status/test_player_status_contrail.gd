extends GutTest

const PLANT_SCENE := preload("res://scenes/main_game/plants/plants/plant.tscn")

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	var _plant: Plant
	func get_current_player_plant() -> Plant:
		return _plant

# ----- Helpers -----

func _make_plant(light_max: int = 20, water_max: int = 20) -> Plant:
	var plant: Plant = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	var pd := PlantData.new()
	pd.light = light_max
	pd.water = water_max
	plant.data = pd
	return plant

func _make_status(value: int, stack_count: int) -> PlayerStatusContrail:
	var s := PlayerStatusContrail.new()
	add_child_autofree(s)
	var sd := StatusData.new()
	sd.data["value"] = value
	s.data = sd
	s.stack = stack_count
	return s

# ----- has_player_move_hook -----

func test_has_player_move_hook_returns_true() -> void:
	var s := PlayerStatusContrail.new()
	add_child_autofree(s)
	assert_true(s.has_player_move_hook(null))

# ----- handle_player_move_hook -----

func test_handle_increases_plant_water_by_stack_times_value() -> void:
	var plant := _make_plant()
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	cm._plant = plant
	await s.handle_player_move_hook(cm)
	assert_eq(plant.water.value, 6)
