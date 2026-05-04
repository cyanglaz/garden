extends GutTest


class FakeGUIToolCardButton extends GUIToolCardButton:
	# Lightweight stand-in; overrides any method that touches @onready children
	# so tests can exercise ToolManager without instancing the full button scene.
	func play_use_animation() -> void:
		pass


class FakeGUIToolCardContainer extends GUIToolCardContainer:
	var cards_by_tool: Dictionary = {}

	func register_tool(tool_data: ToolData) -> void:
		var card := FakeGUIToolCardButton.new()
		add_child(card)
		cards_by_tool[tool_data.id] = card

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

	func queue_tool_application(combat_main: CombatMain, _tool_data: ToolData, context: Dictionary) -> void:
		var request := CombatQueueRequest.new()
		request.callback = func(_cm: CombatMain) -> void:
			if context["skip"]:
				return
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
	combat_main.energy_tracker.setup(10, 10)
	manager.is_mid_turn = true
	manager._tool_applier = FakeToolApplier.new(second_tool)

	var started_ids: Array[String] = []
	var completed_ids: Array[String] = []
	manager.tool_application_started.connect(func(tool_data: ToolData) -> void: started_ids.append(tool_data.id))
	manager.tool_application_completed.connect(func(tool_data: ToolData) -> void: completed_ids.append(tool_data.id))

	manager.queue_apply_tool(combat_main, first_tool)
	manager.queue_apply_tool(combat_main, second_tool)
	await _await_queue_idle(combat_main.combat_queue_manager)

	assert_eq(started_ids, ["first"])
	assert_eq(completed_ids, ["first"])
	assert_eq(manager.tool_deck.hand.size(), 0)
	combat_main.free()
	gui_container.free()

func test_queued_tool_bails_when_energy_is_insufficient_at_execution_time() -> void:
	var tool_data := _make_tool_data("costly")
	tool_data.energy_cost = 1
	var gui_container := FakeGUIToolCardContainer.new()
	autofree(gui_container)
	var manager := ToolManager.new([tool_data], gui_container)
	manager.tool_deck.draw_pool = manager.tool_deck.pool.duplicate()
	var hand: Array = manager.tool_deck.draw(1)
	var costly_tool: ToolData = hand[0]
	gui_container.register_tool(costly_tool)

	var combat_main := FakeCombatMain.new()
	autofree(combat_main)
	combat_main.tool_manager = manager
	combat_main.energy_tracker.setup(0, 0)
	manager.is_mid_turn = true

	var started_ids: Array[String] = []
	var bailed_ids: Array[String] = []
	var completed_ids: Array[String] = []
	manager.tool_application_started.connect(func(td: ToolData) -> void: started_ids.append(td.id))
	manager.tool_application_bailed.connect(func(td: ToolData) -> void: bailed_ids.append(td.id))
	manager.tool_application_completed.connect(func(td: ToolData) -> void: completed_ids.append(td.id))
	watch_signals(Events)

	manager.queue_apply_tool(combat_main, costly_tool)
	await _await_queue_idle(combat_main.combat_queue_manager)

	assert_eq(started_ids, [])
	assert_eq(bailed_ids, ["costly"])
	assert_eq(completed_ids, [])
	assert_eq(manager.number_of_card_used_this_turn, 0)
	assert_true(manager.tool_deck.hand.has(costly_tool))
	assert_signal_emitted_with_parameters(Events, "request_show_warning", [WarningManager.WarningType.INSUFFICIENT_ENERGY])
