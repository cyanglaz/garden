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

func _make_trinket() -> PlayerTrinketSaltGrinder:
	var t := add_child_autofree(PlayerTrinketSaltGrinder.new())
	var td := TrinketData.new()
	td.data["pest"] = 2
	td.data["fungus"] = 1
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

func test_handle_start_turn_applies_pest_action() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	await t.handle_start_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[0].type, ActionData.ActionType.PEST)

func test_handle_start_turn_pest_is_decrease() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	await t.handle_start_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[0].operator_type, ActionData.OperatorType.DECREASE)

func test_handle_start_turn_pest_value_from_data() -> void:
	var t := add_child_autofree(PlayerTrinketSaltGrinder.new())
	var td := TrinketData.new()
	td.data["pest"] = 5
	td.data["fungus"] = 1
	t.data = td
	var cm := FakeCombatMain.new()
	await t.handle_start_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[0].value, 5)

func test_handle_start_turn_applies_fungus_action() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	await t.handle_start_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[1].type, ActionData.ActionType.FUNGUS)

func test_handle_start_turn_fungus_is_decrease() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	await t.handle_start_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[1].operator_type, ActionData.OperatorType.DECREASE)

func test_handle_start_turn_fungus_value_from_data() -> void:
	var t := add_child_autofree(PlayerTrinketSaltGrinder.new())
	var td := TrinketData.new()
	td.data["pest"] = 1
	td.data["fungus"] = 4
	t.data = td
	var cm := FakeCombatMain.new()
	await t.handle_start_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[1].value, 4)
