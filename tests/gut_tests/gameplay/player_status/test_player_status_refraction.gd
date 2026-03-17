extends GutTest

const PLANT_SCENE := preload("res://scenes/main_game/plants/plants/plant.tscn")

# ----- Helpers -----

func _make_plant(light_max: int = 20, water_max: int = 20) -> Plant:
	var plant: Plant = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	var pd := PlantData.new()
	pd.light = light_max
	pd.water = water_max
	plant.data = pd
	return plant

func _make_status(value: int, stack_count: int) -> PlayerRefraction:
	var s := PlayerRefraction.new()
	add_child_autofree(s)
	var sd := StatusData.new()
	sd.data["value"] = value
	s.data = sd
	s.stack = stack_count
	return s

# ----- has_target_plant_water_update_hook -----

func test_has_hook_true_for_positive_diff() -> void:
	var s := PlayerRefraction.new()
	add_child_autofree(s)
	assert_true(s.has_target_plant_water_update_hook(null, null, 1))

func test_has_hook_false_for_zero_diff() -> void:
	var s := PlayerRefraction.new()
	add_child_autofree(s)
	assert_false(s.has_target_plant_water_update_hook(null, null, 0))

func test_has_hook_false_for_negative_diff() -> void:
	var s := PlayerRefraction.new()
	add_child_autofree(s)
	assert_false(s.has_target_plant_water_update_hook(null, null, -1))

# ----- handle_target_plant_water_update_hook -----

func test_handle_increases_plant_light_by_stack_times_value() -> void:
	var plant := _make_plant()
	var s := _make_status(4, 2)
	await s.handle_target_plant_water_update_hook(null, plant, 1)
	assert_eq(plant.light.value, 8)
