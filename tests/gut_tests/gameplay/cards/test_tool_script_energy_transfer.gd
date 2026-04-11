extends GutTest

class FakePlant extends Plant:
	var recorded_actions: Array = []
	var water_val: int = 0
	var light_val: int = 0

	func apply_actions(actions: Array, _combat_main: CombatMain) -> void:
		for action in actions:
			recorded_actions.append(action)
			match action.type:
				ActionData.ActionType.WATER:
					water_val = action.value
				ActionData.ActionType.LIGHT:
					light_val = action.value

class FakePlantWithBloom extends FakePlant:
	var max_val: int = 99

	func apply_actions(actions: Array, combat_main: CombatMain) -> void:
		if water_val >= max_val and light_val >= max_val:
			return
		super.apply_actions(actions, combat_main)

class FakeCombatMain extends CombatMain:
	var fake_plant: FakePlant = null
	func get_current_player_plant() -> Plant:
		return fake_plant

func _make_script() -> ToolScriptEnergyTransfer:
	return ToolScriptEnergyTransfer.new()

func _make_plant(water: int, light: int) -> FakePlant:
	var p := FakePlant.new()
	autofree(p)
	p.water.setup(0, 99)
	p.water.value = water
	p.light.setup(0, 99)
	p.light.value = light
	return p

func _make_combat_main(plant: FakePlant) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.fake_plant = plant
	return cm

func test_need_select_field_is_true() -> void:
	assert_true(_make_script().need_select_field())

func test_has_field_action_is_true() -> void:
	assert_true(_make_script().has_field_action())

func test_water_becomes_original_light() -> void:
	var plant := _make_plant(3, 5)
	var cm := _make_combat_main(plant)
	await _make_script().apply_tool(cm, null, [])
	assert_eq(plant.water_val, 5)

func test_light_becomes_original_water() -> void:
	var plant := _make_plant(3, 5)
	var cm := _make_combat_main(plant)
	await _make_script().apply_tool(cm, null, [])
	assert_eq(plant.light_val, 3)

func test_swap_when_both_zero() -> void:
	var plant := _make_plant(0, 0)
	var cm := _make_combat_main(plant)
	await _make_script().apply_tool(cm, null, [])
	assert_eq(plant.water_val, 0)
	assert_eq(plant.light_val, 0)

func test_swap_when_water_zero() -> void:
	var plant := _make_plant(0, 4)
	var cm := _make_combat_main(plant)
	await _make_script().apply_tool(cm, null, [])
	assert_eq(plant.water_val, 4)
	assert_eq(plant.light_val, 0)

func test_swap_when_light_zero() -> void:
	var plant := _make_plant(7, 0)
	var cm := _make_combat_main(plant)
	await _make_script().apply_tool(cm, null, [])
	assert_eq(plant.water_val, 0)
	assert_eq(plant.light_val, 7)

func test_actions_use_equal_to_operator() -> void:
	var plant := _make_plant(2, 6)
	var cm := _make_combat_main(plant)
	await _make_script().apply_tool(cm, null, [])
	assert_eq(plant.recorded_actions.size(), 2)
	for action in plant.recorded_actions:
		assert_eq(action.operator_type, ActionData.OperatorType.EQUAL_TO)

func test_swap_is_atomic_when_water_action_causes_bloom() -> void:
	# Regression: water=3, light=5, max=5.
	# Setting water to 5 (= original_light) would cause bloom.
	# Old two-call code would skip the LIGHT action, leaving light at 5.
	# Single-call code applies both actions before any bloom check on the next call.
	var p := FakePlantWithBloom.new()
	autofree(p)
	p.water.setup(0, 99)
	p.water.value = 3
	p.light.setup(0, 99)
	p.light.value = 5
	p.water_val = 3
	p.light_val = 5
	p.max_val = 5
	var cm := _make_combat_main(p)
	await _make_script().apply_tool(cm, null, [])
	assert_eq(p.water_val, 5, "Water should be set to original light value")
	assert_eq(p.light_val, 3, "Light should be set to original water value even when water action causes bloom")
