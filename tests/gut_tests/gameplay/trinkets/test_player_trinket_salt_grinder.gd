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

func _add_field_status(plant: Plant, action_type: ActionData.ActionType, value: int) -> void:
	var action := ActionData.new()
	action.type = action_type
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = value
	await plant.apply_actions([action])

func _make_trinket(pest: int = 2, fungus: int = 1) -> PlayerTrinketSaltGrinder:
	var t := add_child_autofree(PlayerTrinketSaltGrinder.new())
	var td := TrinketData.new()
	td.data["pest"] = pest
	td.data["fungus"] = fungus
	t.data = td
	return t

# ----- has_*_hook -----

func test_has_start_turn_hook_returns_true() -> void:
	var t := add_child_autofree(PlayerTrinketSaltGrinder.new())
	assert_true(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := add_child_autofree(PlayerTrinketSaltGrinder.new())
	assert_false(t.has_end_turn_hook(null))

# ----- handle_start_turn_hook -----

func test_handle_decreases_pest_by_data_value() -> void:
	var plant := _make_plant()
	await _add_field_status(plant, ActionData.ActionType.PEST, 5)
	var t := _make_trinket(2, 1)
	var cm := FakeCombatMain.new()
	cm.plant_field_container._plant = plant
	await t.handle_start_turn_hook(cm)
	assert_eq(plant.field_status_container._get_field_status("pest").stack, 3)

func test_handle_decreases_fungus_by_data_value() -> void:
	var plant := _make_plant()
	await _add_field_status(plant, ActionData.ActionType.FUNGUS, 5)
	var t := _make_trinket(2, 1)
	var cm := FakeCombatMain.new()
	cm.plant_field_container._plant = plant
	await t.handle_start_turn_hook(cm)
	assert_eq(plant.field_status_container._get_field_status("fungus").stack, 4)
