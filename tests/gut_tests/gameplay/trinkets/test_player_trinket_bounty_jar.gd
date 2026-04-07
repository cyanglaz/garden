extends GutTest

class FakeCombatMain extends CombatMain:
	pass

class FakeFieldStatusContainer extends FieldStatusContainer:
	var _pest_stack: int = 0
	func get_status_stack(status_id: String) -> int:
		if status_id == "pest":
			return _pest_stack
		return 0

class FakePlant extends Plant:
	pass

class FakePlantFieldContainerBounty extends PlantFieldContainer:
	var plant_at_field: Plant = null
	func get_plant(_index: int) -> Plant:
		return plant_at_field

func _make_trinket() -> PlayerTrinketBountyJar:
	var t := PlayerTrinketBountyJar.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"gold"] = "3"
	t.data = td
	return t

func _make_plant(pest_stack: int) -> FakePlant:
	var p := FakePlant.new()
	autofree(p)
	var fsc := FakeFieldStatusContainer.new()
	autofree(fsc)
	fsc._pest_stack = pest_stack
	p.field_status_container = fsc
	return p

func _make_tool_data(action_type: ActionData.ActionType, operator_type: ActionData.OperatorType, value: int) -> ToolData:
	var td := ToolData.new()
	var action := ActionData.new()
	action.type = action_type
	action.operator_type = operator_type
	action.value = value
	td.actions.append(action)
	return td

# ----- _will_decrease_pest_on_application -----

func test_false_when_plant_has_no_pest_and_decrease_action() -> void:
	var t := _make_trinket()
	var plant := _make_plant(0)
	var tool_data := _make_tool_data(ActionData.ActionType.PEST, ActionData.OperatorType.DECREASE, 1)
	assert_false(t._will_decrease_pest_on_application(tool_data, plant))

func test_true_when_plant_has_pest_and_decrease_action() -> void:
	var t := _make_trinket()
	var plant := _make_plant(2)
	var tool_data := _make_tool_data(ActionData.ActionType.PEST, ActionData.OperatorType.DECREASE, 1)
	assert_true(t._will_decrease_pest_on_application(tool_data, plant))

func test_false_when_plant_has_pest_and_increase_action() -> void:
	var t := _make_trinket()
	var plant := _make_plant(2)
	var tool_data := _make_tool_data(ActionData.ActionType.PEST, ActionData.OperatorType.INCREASE, 1)
	assert_false(t._will_decrease_pest_on_application(tool_data, plant))

func test_false_when_plant_has_pest_and_non_pest_action() -> void:
	var t := _make_trinket()
	var plant := _make_plant(2)
	var tool_data := _make_tool_data(ActionData.ActionType.WATER, ActionData.OperatorType.INCREASE, 1)
	assert_false(t._will_decrease_pest_on_application(tool_data, plant))

func test_true_when_equal_to_value_less_than_pest_count() -> void:
	var t := _make_trinket()
	var plant := _make_plant(2)
	var tool_data := _make_tool_data(ActionData.ActionType.PEST, ActionData.OperatorType.EQUAL_TO, 1)
	assert_true(t._will_decrease_pest_on_application(tool_data, plant))

func test_false_when_equal_to_value_greater_than_pest_count() -> void:
	var t := _make_trinket()
	var plant := _make_plant(2)
	var tool_data := _make_tool_data(ActionData.ActionType.PEST, ActionData.OperatorType.EQUAL_TO, 3)
	assert_false(t._will_decrease_pest_on_application(tool_data, plant))

func test_false_when_no_pest_and_equal_to_action() -> void:
	var t := _make_trinket()
	var plant := _make_plant(0)
	var tool_data := _make_tool_data(ActionData.ActionType.PEST, ActionData.OperatorType.EQUAL_TO, 0)
	assert_false(t._will_decrease_pest_on_application(tool_data, plant))

# ----- handle_pre_tool_application_hook (hook animation) -----

func test_handle_pre_tool_application_hook_emits_hook_animation_signal() -> void:
	var t := _make_trinket()
	t.data.id = "bounty_jar"
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := FakeCombatMain.new()
	autofree(cm)
	var pfc := FakePlantFieldContainerBounty.new()
	autofree(pfc)
	pfc.plant_at_field = _make_plant(2)
	cm.plant_field_container = pfc
	var p := Player.new()
	autofree(p)
	var psc := PlayerStatusContainer.new()
	autofree(psc)
	p.player_status_container = psc
	p.max_plants_index = 3
	p.current_field_index = 0
	cm.player = p
	var tool_data := _make_tool_data(ActionData.ActionType.PEST, ActionData.OperatorType.DECREASE, 1)
	t._handle_pre_tool_application_hook(cm, tool_data)
	assert_true(saw_anim[0])

# ----- other hooks absent -----

func test_has_no_tool_application_hook() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	assert_false(t.has_tool_application_hook(cm, null))

func test_has_no_start_turn_hook() -> void:
	assert_false(_make_trinket().has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	assert_false(_make_trinket().has_end_turn_hook(null))

func test_has_no_draw_hook() -> void:
	assert_false(_make_trinket().has_draw_hook(null, []))

func test_has_no_discard_hook() -> void:
	assert_false(_make_trinket().has_discard_hook(null, []))
