extends GutTest


class FakePlayerActionApplier extends PlayerActionApplier:
	var applied_values: Array[int] = []

	func apply_action(action: ActionData, _combat_main: CombatMain, _secondary_card_datas: Array) -> void:
		applied_values.append(action.value)


class FakePlantActionApplier extends PlantActionApplier:
	var applied_values: Array[int] = []

	func apply_action(action: ActionData, _target_plant: Plant, _combat_main: CombatMain) -> void:
		applied_values.append(action.value)


class ScriptWeatherAbility extends WeatherAbility:
	var player_script_calls := 0
	var plant_script_calls := 0

	func _apply_to_player_with_script(_combat_main: CombatMain) -> void:
		player_script_calls += 1

	func _apply_to_plant_with_script(_plant: Plant, _combat_main: CombatMain) -> void:
		plant_script_calls += 1


func _make_combat_main() -> CombatMain:
	var cm := CombatMain.new()
	autofree(cm)
	return cm


func _make_queue(cm: CombatMain) -> CombatQueueManager:
	var q := CombatQueueManager.new()
	q.setup(cm)
	return q


func _make_action(category: ActionData.ActionCategory, value: int) -> ActionData:
	var action := ActionData.new()
	action.action_category = category
	action.value = value
	action.value_type = ActionData.ValueType.NUMBER
	action.operator_type = ActionData.OperatorType.INCREASE
	action.type = ActionData.ActionType.ENERGY if category == ActionData.ActionCategory.PLAYER else ActionData.ActionType.WATER
	return action


func _make_weather_ability(action_datas: Array[ActionData]) -> WeatherAbility:
	var ability := WeatherAbility.new()
	autofree(ability)
	var data := WeatherAbilityData.new()
	data.action_datas = action_datas
	ability.weather_ability_data = data
	return ability


func _connect_queue_requests(q: CombatQueueManager) -> Callable:
	var callable := func(request: CombatQueueRequest) -> void:
		q.push_request(request)
	Events.request_combat_queue_push.connect(callable)
	return callable


func _disconnect_queue_requests(callable: Callable) -> void:
	if Events.request_combat_queue_push.is_connected(callable):
		Events.request_combat_queue_push.disconnect(callable)


func _await_queue_idle(q: CombatQueueManager) -> void:
	var safety := 0
	while q.is_queue_busy() or q.get_queue_size() > 0:
		await get_tree().process_frame
		safety += 1
		assert_lt(safety, 120, "queue should drain")


func test_queue_player_actions_runs_in_original_order_after_current_item() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var ability := _make_weather_ability([
		_make_action(ActionData.ActionCategory.PLAYER, 1),
		_make_action(ActionData.ActionCategory.PLAYER, 2),
	])
	var applier := FakePlayerActionApplier.new()
	ability.player_actions_applier = applier
	var queue_connection := _connect_queue_requests(q)

	var host_item := CombatQueueItem.new()
	host_item.callback = func(_cm: CombatMain) -> void:
		ability.queue_player_actions(cm)
	q.push_items(false, [host_item])
	await _await_queue_idle(q)
	_disconnect_queue_requests(queue_connection)

	assert_eq(applier.applied_values, [1, 2])


func test_queue_plant_actions_runs_in_original_order_after_current_item() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var plant := Plant.new()
	autofree(plant)
	var ability := _make_weather_ability([
		_make_action(ActionData.ActionCategory.FIELD, 1),
		_make_action(ActionData.ActionCategory.FIELD, 2),
	])
	var applier := FakePlantActionApplier.new()
	ability.plant_actions_applier = applier
	var queue_connection := _connect_queue_requests(q)

	var host_item := CombatQueueItem.new()
	host_item.callback = func(_cm: CombatMain) -> void:
		ability.queue_plant_actions(plant, cm)
	q.push_items(false, [host_item])
	await _await_queue_idle(q)
	_disconnect_queue_requests(queue_connection)

	assert_eq(applier.applied_values, [1, 2])


func test_queue_player_actions_uses_script_request_when_no_player_actions() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var ability := ScriptWeatherAbility.new()
	autofree(ability)
	var data := WeatherAbilityData.new()
	data.action_datas = []
	ability.weather_ability_data = data
	var queue_connection := _connect_queue_requests(q)

	var host_item := CombatQueueItem.new()
	host_item.callback = func(_cm: CombatMain) -> void:
		ability.queue_player_actions(cm)
	q.push_items(false, [host_item])
	await _await_queue_idle(q)
	_disconnect_queue_requests(queue_connection)

	assert_eq(ability.player_script_calls, 1)
