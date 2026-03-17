extends GutTest

# ----- Stubs -----

class FakePlant:
	var last_actions: Array = []
	func apply_actions(actions: Array) -> void:
		last_actions = actions

class FakePlantFieldContainer:
	var _plant := FakePlant.new()
	func get_plant(_index: int) -> FakePlant:
		return _plant

class FakePlayer:
	var current_field_index: int = 0

class FakeCombatMain:
	var player := FakePlayer.new()
	var plant_field_container := FakePlantFieldContainer.new()

# ----- Helpers -----

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

func test_handle_applies_water_increase() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	await t.handle_end_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[0].type, ActionData.ActionType.WATER)
	assert_eq(cm.plant_field_container._plant.last_actions[0].operator_type, ActionData.OperatorType.INCREASE)

func test_handle_water_value_from_data() -> void:
	var t := _make_trinket(6)
	var cm := FakeCombatMain.new()
	await t.handle_end_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[0].value, 6)
