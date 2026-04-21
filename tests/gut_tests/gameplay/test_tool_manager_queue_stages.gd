extends GutTest


class FakeGUIToolCardButton extends GUIToolCardButton:
	# Lightweight stand-in; overrides any method that touches @onready children
	# so tests can exercise ToolManager without instancing the full button scene.
	func play_use_animation() -> void:
		pass


class FakeGUIToolCardContainer extends GUIToolCardContainer:
	var cards_by_tool: Dictionary = {}

	func register_tool(tool_data: ToolData) -> void:
		cards_by_tool[tool_data.id] = FakeGUIToolCardButton.new()

	func clear_tool(tool_data: ToolData) -> void:
		var card: GUIToolCardButton = cards_by_tool.get(tool_data.id, null)
		if card:
			card.free()
		cards_by_tool.erase(tool_data.id)

	func find_card(tool_data: ToolData) -> GUIToolCardButton:
		if !tool_data:
			return null
		return cards_by_tool.get(tool_data.id, null)

	func animate_discard(discarding_tool_datas: Array, _combat_main: CombatMain) -> void:
		for tool_data: ToolData in discarding_tool_datas:
			clear_tool(tool_data)
		await Util.await_for_tiny_time()

	func animate_exhaust(exhausting_tool_datas: Array, _combat_main: CombatMain) -> void:
		for tool_data: ToolData in exhausting_tool_datas:
			clear_tool(tool_data)
		await Util.await_for_tiny_time()


class FakeToolApplier extends ToolApplier:
	var _tool_to_discard: ToolData
	var _discarded := false

	func _init(tool_to_discard: ToolData) -> void:
		_tool_to_discard = tool_to_discard

	func queue_tool_application(combat_main: CombatMain, _tool_data: ToolData, _gui_tool_card: GUIToolCardButton, _gui_tool_card_container: GUIToolCardContainer) -> void:
		var request := CombatQueueRequest.new()
		request.callback = func(_cm: CombatMain) -> void:
			if !_discarded and _tool_to_discard and combat_main.tool_manager.tool_deck.hand.has(_tool_to_discard):
				_discarded = true
				await combat_main.discard_cards([_tool_to_discard])
			await Util.await_for_tiny_time()
		Events.request_combat_queue_push.emit(request)


class FakeCombatMain extends CombatMain:
	func _init() -> void:
		player = Player.new()
		player.player_upgrades_manager = PlayerUpgradesManager.new()
		add_child(player)
		plant_field_container = PlantFieldContainer.new()
		add_child(plant_field_container)
		combat_queue_manager = CombatQueueManager.new()
		combat_queue_manager.setup(self)
		if !Events.request_combat_queue_push.is_connected(_on_request_combat_queue_push):
			Events.request_combat_queue_push.connect(_on_request_combat_queue_push)

	func _on_request_combat_queue_push(request) -> void:
		combat_queue_manager.push_request(request)


func _await_queue_idle(q: CombatQueueManager) -> void:
	var safety := 0
	while q.is_queue_busy() or q.get_queue_size() > 0:
		await get_tree().process_frame
		safety += 1
		assert_lt(safety, 180, "queue should drain")


func _make_tool_data(id: String) -> ToolData:
	var tool_data := ToolData.new()
	tool_data.id = id
	var action := ActionData.new()
	action.action_category = ActionData.ActionCategory.PLAYER
	action.type = ActionData.ActionType.ENERGY
	action.value = 0
	tool_data.actions = [action]
	autofree(tool_data)
	return tool_data


func test_first_tool_can_discard_second_queued_tool_without_crash() -> void:
	var gui_container := FakeGUIToolCardContainer.new()

	var manager := ToolManager.new(
		[
			_make_tool_data("first"),
			_make_tool_data("second"),
		],
		gui_container,
	)

	manager.tool_deck.draw_pool = manager.tool_deck.pool.duplicate()
	var hand: Array = manager.tool_deck.draw(2)
	var first_tool: ToolData = hand[0]
	var second_tool: ToolData = hand[1]
	gui_container.register_tool(first_tool)
	gui_container.register_tool(second_tool)

	var combat_main := FakeCombatMain.new()
	combat_main.tool_manager = manager
	manager.is_mid_turn = true
	manager._tool_applier = FakeToolApplier.new(second_tool)

	var started_ids: Array[String] = []
	var completed_ids: Array[String] = []
	var error_counter := {"value": 0}
	manager.tool_application_started.connect(func(tool_data: ToolData) -> void: started_ids.append(tool_data.id))
	manager.tool_application_completed.connect(func(tool_data: ToolData) -> void: completed_ids.append(tool_data.id))
	manager.tool_application_error.connect(func(_tool_data: ToolData, _error_message: String) -> void: error_counter["value"] += 1)

	manager.queue_apply_tool(combat_main, first_tool)
	manager.queue_apply_tool(combat_main, second_tool)
	await _await_queue_idle(combat_main.combat_queue_manager)

	assert_eq(started_ids, ["first"])
	assert_eq(completed_ids, ["first"])
	assert_eq(error_counter["value"], 0)
	assert_eq(manager.tool_deck.hand.size(), 0)
	combat_main.free()
	gui_container.free()
