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

func _make_status(value: int, stack: int) -> PlayerStatusRegenerator:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	var sd := StatusData.new()
	sd.data["value"] = value
	s.data = sd
	s.stack = stack
	return s

# ----- has_stack_update_hook -----

func test_has_hook_true_for_momentum_negative_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_true(s.has_stack_update_hook(null, "momentum", -1))

func test_has_hook_false_for_momentum_zero_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "momentum", 0))

func test_has_hook_false_for_momentum_positive_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "momentum", 1))

func test_has_hook_false_for_other_status_negative_diff() -> void:
	var s := PlayerStatusRegenerator.new()
	add_child_autofree(s)
	assert_false(s.has_stack_update_hook(null, "water", -1))

# ----- handle_stack_update_hook -----

func test_handle_increases_plant_light_by_stack_times_value() -> void:
	var plant := _make_plant()
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	cm._plant = plant
	await s.handle_stack_update_hook(cm, "momentum", -1)
	assert_eq(plant.light.value, 6)
