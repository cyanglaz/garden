extends GutTest

const PLANT_SCENE := preload("res://scenes/main_game/plants/plants/plant.tscn")

# ----- Stubs -----

class FakePlantFieldContainer:
	var plants: Array = []

class FakeCombatMain:
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

func _make_tool(energy_cost: int) -> ToolData:
	var td := ToolData.new()
	td.energy_cost = energy_cost
	return td

# ----- has_tool_application_hook -----

func test_has_hook_true_for_zero_energy_cost() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	assert_true(s.has_tool_application_hook(null, _make_tool(0)))

func test_has_hook_false_for_nonzero_energy_cost() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	assert_false(s.has_tool_application_hook(null, _make_tool(1)))

func test_has_hook_false_for_high_energy_cost() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	assert_false(s.has_tool_application_hook(null, _make_tool(5)))

# ----- handle_tool_application_hook -----
# Loads two real Plant scenes; the typed `for plant:Plant in plants` loop
# inside the handler requires genuine Plant instances.
# All plants' light rises by `stack` (ALL_FIELDS LIGHT INCREASE action).

func test_handle_applies_light_increase_to_all_plants() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	var sd := StatusData.new()
	s.data = sd
	s.stack = 3
	var p1 := _make_plant()
	var p2 := _make_plant()
	var cm := FakeCombatMain.new()
	cm.plant_field_container.plants = [p1, p2]
	await s.handle_tool_application_hook(cm, _make_tool(0))
	assert_eq(p1.light.value, 3)
	assert_eq(p2.light.value, 3)

func test_handle_light_value_equals_stack() -> void:
	var s := add_child_autofree(PlayerStatusCleanEnergy.new())
	var sd := StatusData.new()
	s.data = sd
	s.stack = 5
	var plant := _make_plant()
	var cm := FakeCombatMain.new()
	cm.plant_field_container.plants = [plant]
	await s.handle_tool_application_hook(cm, _make_tool(0))
	assert_eq(plant.light.value, 5)
