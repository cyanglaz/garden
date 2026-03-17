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
	var max_plants_index: int = 3

class FakeCombatMain:
	var player := FakePlayer.new()
	var plant_field_container := FakePlantFieldContainer.new()

# ----- Helpers -----

func _make_trinket(light_value: int = 3) -> PlayerTrinketSunShard:
	var t := add_child_autofree(PlayerTrinketSunShard.new())
	var td := TrinketData.new()
	td.data["light"] = light_value
	t.data = td
	return t

# ----- has_end_turn_hook -----

func test_has_hook_true_at_index_zero() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	cm.player.current_field_index = 0
	cm.player.max_plants_index = 3
	assert_true(t.has_end_turn_hook(cm))

func test_has_hook_true_at_max_index() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	cm.player.current_field_index = 3
	cm.player.max_plants_index = 3
	assert_true(t.has_end_turn_hook(cm))

func test_has_hook_false_at_middle_index() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	cm.player.current_field_index = 1
	cm.player.max_plants_index = 3
	assert_false(t.has_end_turn_hook(cm))

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

# ----- handle_end_turn_hook -----

func test_handle_applies_light_increase() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	cm.player.current_field_index = 0
	cm.player.max_plants_index = 3
	await t.handle_end_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[0].type, ActionData.ActionType.LIGHT)
	assert_eq(cm.plant_field_container._plant.last_actions[0].operator_type, ActionData.OperatorType.INCREASE)

func test_handle_light_value_from_data() -> void:
	var t := _make_trinket(7)
	var cm := FakeCombatMain.new()
	cm.player.current_field_index = 0
	cm.player.max_plants_index = 3
	await t.handle_end_turn_hook(cm)
	assert_eq(cm.plant_field_container._plant.last_actions[0].value, 7)
