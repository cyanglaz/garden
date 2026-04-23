extends GutTest

func _make_trinket() -> PlayerTrinketRecyclerBadge:
	var t := PlayerTrinketRecyclerBadge.new()
	add_child_autofree(t)
	t.data = TrinketData.new()
	return t

func _make_free_water() -> ToolData:
	var td := ToolData.new()
	td.id = "free_water"
	var action := ActionData.new()
	action.type = ActionData.ActionType.WATER
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = 1
	td.actions = [action]
	return td

func _make_combat_main() -> CombatMain:
	var cm := CombatMain.new()
	autofree(cm)
	return cm

# ----- has_pool_updated_hook -----

func test_has_hook_true_when_pool_contains_free_water() -> void:
	var t := _make_trinket()
	var fw := _make_free_water()
	assert_true(t.has_pool_updated_hook(null, [fw]))

func test_has_hook_false_when_no_free_water_in_pool() -> void:
	var t := _make_trinket()
	var other := ToolData.new()
	other.id = "basic_water"
	assert_false(t.has_pool_updated_hook(null, [other]))

func test_has_hook_false_with_empty_pool() -> void:
	var t := _make_trinket()
	assert_false(t.has_pool_updated_hook(null, []))

# ----- handle_pool_updated_hook -----

func test_handle_hook_increases_modified_value_by_one() -> void:
	var t := _make_trinket()
	var fw := _make_free_water()
	t._handle_pool_updated_hook(null, [fw])
	assert_eq(fw.actions[0].modified_value, 1)

func test_handle_hook_does_not_double_apply() -> void:
	var t := _make_trinket()
	var fw := _make_free_water()
	t._handle_pool_updated_hook(null, [fw])
	t._handle_pool_updated_hook(null, [fw])
	assert_eq(fw.actions[0].modified_value, 1)

func test_handle_hook_ignores_non_free_water() -> void:
	var t := _make_trinket()
	var other := ToolData.new()
	other.id = "basic_water"
	var action := ActionData.new()
	action.type = ActionData.ActionType.WATER
	action.modified_value = 0
	other.actions = [action]
	t._handle_pool_updated_hook(null, [other])
	assert_eq(other.actions[0].modified_value, 0)

# ----- absent hooks -----

func test_has_start_turn_hook_on_day_0() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main()
	assert_true(t.has_start_turn_hook(cm))

func test_has_start_turn_hook_on_day_1() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main()
	cm.day_manager.day = 1
	assert_false(t.has_start_turn_hook(cm))

func test_has_no_end_turn_hook() -> void:
	assert_false(_make_trinket().has_end_turn_hook(null))

func test_has_no_discard_hook() -> void:
	assert_false(_make_trinket().has_discard_hook(null, []))

func test_has_no_tool_application_hook() -> void:
	assert_false(_make_trinket().has_tool_application_hook(null, null))
