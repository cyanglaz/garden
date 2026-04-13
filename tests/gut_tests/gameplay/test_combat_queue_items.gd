extends GutTest

func _make_action() -> ActionData:
	var ad := ActionData.new()
	ad.type = ActionData.ActionType.WATER
	ad.value_type = ActionData.ValueType.NUMBER
	ad.operator_type = ActionData.OperatorType.INCREASE
	ad.value = 1
	return ad


func test_actions_item_duplicates_actions_array() -> void:
	var inner := [_make_action()]
	var item = CombatQueueActionsItem.new(inner, null)
	inner.clear()
	assert_eq(item.actions.size(), 1)


func test_actions_item_tool_card_preserved() -> void:
	var item = CombatQueueActionsItem.new([], null)
	assert_eq(item.tool_card, null)


func test_callable_item_stores_callable() -> void:
	var ran := [false]
	var cm := CombatMain.new()
	autofree(cm)
	var c := func(p_cm: CombatMain) -> void:
		ran[0] = true
		assert_eq(p_cm, cm)
	var item = CombatQueueCallableItem.new(c)
	item.callback.call(cm)
	assert_true(ran[0])
