extends GutTest

const PLANT_SCENE := preload("res://scenes/main_game/plants/plants/plant.tscn")

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	var _plant: Plant
	func get_current_player_plant() -> Plant:
		return _plant

# ----- Helpers -----

func _make_plant(light_max: int = 20, water_max: int = 40) -> Plant:
	var plant: Plant = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	var pd := PlantData.new()
	pd.light = light_max
	pd.water = water_max
	plant.data = pd
	return plant

func _make_status(value: int, stack_count: int) -> PlayerStatusCondensation:
	var s := PlayerStatusCondensation.new()
	add_child_autofree(s)
	var sd := StatusData.new()
	sd.data["value"] = value
	s.data = sd
	s.stack = stack_count
	return s

# ----- has_discard_hook -----

func test_has_discard_hook_returns_true() -> void:
	var s := PlayerStatusCondensation.new()
	add_child_autofree(s)
	assert_true(s.has_discard_hook(null, []))

func test_has_discard_hook_true_with_cards() -> void:
	var s := PlayerStatusCondensation.new()
	add_child_autofree(s)
	assert_true(s.has_discard_hook(null, [ToolData.new(), ToolData.new()]))

# ----- handle_discard_hook -----

func test_handle_water_value_is_value_times_stack_times_card_count() -> void:
	# value=3, stack=2, 2 cards → 3 * 2 * 2 = 12
	var plant := _make_plant()
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	cm._plant = plant
	await s.handle_discard_hook(cm, [ToolData.new(), ToolData.new()])
	assert_eq(plant.water.value, 12)

func test_handle_water_scales_with_card_count() -> void:
	# value=2, stack=1, 3 cards → 2 * 1 * 3 = 6
	var plant := _make_plant()
	var s := _make_status(2, 1)
	var cm := FakeCombatMain.new()
	cm._plant = plant
	await s.handle_discard_hook(cm, [ToolData.new(), ToolData.new(), ToolData.new()])
	assert_eq(plant.water.value, 6)
