extends GutTest

const EVENT_DIR := "res://data/events/events"
const OPTION_DIR := "res://data/events/event_options"
const OPTION_SCRIPT_PREFIX := "res://scenes/main_game/event/event_option_scripts/event_option_script_"

func _make_main_game(gold_value: int = 99, hp_value: int = 99) -> MainGame:
	var main_game := MainGame.new()
	main_game.gold = gold_value
	main_game.hp.setup(hp_value, hp_value)
	main_game.card_pool = []
	autofree(main_game)
	return main_game

func _make_event(id_value: String = "test_event") -> EventData:
	var event_data := EventData.new()
	event_data.set("_original_resource_path", "res://fake/%s.tres" % id_value)
	event_data.id = id_value
	event_data.data = {}
	return event_data

func _make_option(script_id: String, data: Dictionary = {}) -> EventOptionData:
	var option_data := EventOptionData.new()
	option_data.set("_original_resource_path", "res://fake/%s.tres" % script_id)
	option_data.id = script_id
	option_data.script_id = script_id
	option_data.data = data.duplicate()
	return option_data

func _load_event_option_script(option_data: EventOptionData) -> EventOptionScript:
	var path := OPTION_SCRIPT_PREFIX + option_data.script_id + ".gd"
	var script_resource := load(path)
	assert_not_null(script_resource, "%s should load" % path)
	var script := script_resource.new() as EventOptionScript
	assert_not_null(script, "%s should create an EventOptionScript" % path)
	return script

func _load_events() -> Array[EventData]:
	var events: Array[EventData] = []
	for path: String in Util.get_all_file_paths(EVENT_DIR, false):
		if !path.ends_with(".tres"):
			continue
		var event_data := load(path) as EventData
		assert_not_null(event_data, "%s should load as EventData" % path)
		events.append(event_data)
	return events

func _load_event_options() -> Array[EventOptionData]:
	var options: Array[EventOptionData] = []
	for path: String in Util.get_all_file_paths(OPTION_DIR, false):
		if !path.ends_with(".tres"):
			continue
		var option_data := load(path) as EventOptionData
		assert_not_null(option_data, "%s should load as EventOptionData" % path)
		options.append(option_data)
	return options

func _load_event_option_contexts() -> Array[Dictionary]:
	var contexts: Array[Dictionary] = []
	for event_data: EventData in _load_events():
		for option_id: String in event_data.option_ids:
			var full_option_id := "%s_%s" % [event_data.id, option_id]
			var path := "%s/event_option_%s.tres" % [OPTION_DIR, full_option_id]
			var option_data := load(path) as EventOptionData
			assert_not_null(option_data, "%s should exist for %s" % [path, event_data.id])
			contexts.append({
				"event": event_data,
				"option": option_data,
			})
	return contexts

func _assert_numeric_data(option_data: EventOptionData, key: String) -> void:
	assert_true(option_data.data.has(key), "%s should have %s" % [option_data.id, key])
	assert_true(str(option_data.data[key]).is_valid_int(), "%s.%s should be numeric" % [option_data.id, key])

func _assert_optional_numeric_data(option_data: EventOptionData, key: String) -> void:
	if option_data.data.has(key):
		assert_true(str(option_data.data[key]).is_valid_int(), "%s.%s should be numeric" % [option_data.id, key])

func test_all_existing_event_option_tres_are_referenced_by_events():
	var referenced_ids := {}
	for context: Dictionary in _load_event_option_contexts():
		var option_data: EventOptionData = context["option"]
		referenced_ids[option_data.id] = true

	var all_options := _load_event_options()
	assert_eq(referenced_ids.size(), all_options.size())
	for option_data: EventOptionData in all_options:
		assert_true(referenced_ids.has(option_data.id), "%s should be referenced by an event" % option_data.id)

func test_all_existing_event_option_tres_resolve_scripts_and_required_data():
	var main_game := _make_main_game()
	for context: Dictionary in _load_event_option_contexts():
		var event_data: EventData = context["event"]
		var option_data: EventOptionData = context["option"]
		assert_false(option_data.id.is_empty())
		assert_false(option_data.script_id.is_empty(), "%s should declare script_id" % option_data.id)

		var script := _load_event_option_script(option_data)
		script.prepare(event_data, main_game, option_data)
		assert_true(script.should_enable(option_data, main_game), "%s should be enabled with enough resources" % option_data.id)

		_assert_optional_numeric_data(option_data, "gold")
		match option_data.script_id:
			"obtain_card":
				assert_true(option_data.data.has("card"), "%s should resolve a card" % option_data.id)
				assert_not_null(MainDatabase.tool_database.get_data_by_id(option_data.data["card"] as String))
				_assert_optional_numeric_data(option_data, "hp")
			"obtain_trinket":
				assert_true(option_data.data.has("trinket"), "%s should resolve a trinket" % option_data.id)
				assert_not_null(MainDatabase.trinket_database.get_data_by_id(option_data.data["trinket"] as String))
			"enchant":
				assert_true(option_data.data.has("enchant"), "%s should resolve an enchant" % option_data.id)
				assert_not_null(MainDatabase.enchant_database.get_data_by_id(option_data.data["enchant"] as String))
				_assert_optional_numeric_data(option_data, "hp")
			"hp":
				_assert_numeric_data(option_data, "hp")
			"max_hp":
				_assert_numeric_data(option_data, "max_hp")
			"pack":
				assert_true(option_data.data.get("pack_type", "common") in ["common", "rare", "legendary"])
			"remove_card", "exit":
				pass
			_:
				fail_test("Unhandled event option script_id: %s" % option_data.script_id)

func test_obtain_card_prepare_copies_event_card_and_run_returns_card():
	var event_data := _make_event("wasp_merchant")
	event_data.data["card"] = "runoff"
	var option_data := _make_option("obtain_card", {"gold": "8"})
	var main_game := _make_main_game()
	var script := EventOptionScriptObtainCard.new()

	script.prepare(event_data, main_game, option_data)
	watch_signals(Events)
	var result: ToolData = await script.run(option_data, main_game)

	assert_eq(option_data.data["card"], "runoff")
	assert_eq(result, MainDatabase.tool_database.get_data_by_id("runoff"))
	assert_signal_emitted_with_parameters(Events, "request_update_gold", [-8, true])

func test_obtain_card_with_hp_cost_emits_hp_decrease():
	var option_data := _make_option("obtain_card", {"card": "runoff", "hp": "1"})
	var main_game := _make_main_game()
	var script := EventOptionScriptObtainCard.new()

	watch_signals(Events)
	var result: ToolData = await script.run(option_data, main_game)

	assert_eq(result, MainDatabase.tool_database.get_data_by_id("runoff"))
	assert_signal_emitted_with_parameters(Events, "request_hp_update", [1, ActionData.OperatorType.DECREASE])

func test_hp_script_emits_hp_increase_and_gold_cost():
	var option_data := _make_option("hp", {"hp": "2", "gold": "10"})
	var main_game := _make_main_game()
	var script := EventOptionScriptHP.new()

	watch_signals(Events)
	var result = await script.run(option_data, main_game)

	assert_null(result)
	assert_signal_emitted_with_parameters(Events, "request_hp_update", [2, ActionData.OperatorType.INCREASE])
	assert_signal_emitted_with_parameters(Events, "request_update_gold", [-10, true])

func test_hp_script_negative_value_emits_hp_decrease():
	var option_data := _make_option("hp", {"hp": "-2"})
	var main_game := _make_main_game()
	var script := EventOptionScriptHP.new()

	watch_signals(Events)
	await script.run(option_data, main_game)

	assert_signal_emitted_with_parameters(Events, "request_hp_update", [-2, ActionData.OperatorType.DECREASE])

func test_max_hp_script_emits_max_hp_increase_and_gold_cost():
	var option_data := _make_option("max_hp", {"max_hp": "1", "gold": "10"})
	var main_game := _make_main_game()
	var script := EventOptionScriptMaxHP.new()

	watch_signals(Events)
	var result = await script.run(option_data, main_game)

	assert_null(result)
	assert_signal_emitted_with_parameters(Events, "request_max_hp_update", [1, ActionData.OperatorType.INCREASE])
	assert_signal_emitted_with_parameters(Events, "request_update_gold", [-10, true])

func test_max_hp_script_negative_value_emits_max_hp_decrease():
	var option_data := _make_option("max_hp", {"max_hp": "-1"})
	var main_game := _make_main_game()
	var script := EventOptionScriptMaxHP.new()

	watch_signals(Events)
	await script.run(option_data, main_game)

	assert_signal_emitted_with_parameters(Events, "request_max_hp_update", [-1, ActionData.OperatorType.DECREASE])

func test_obtain_trinket_prepare_copies_event_trinket_and_run_returns_trinket():
	var event_data := _make_event("vine_cave")
	event_data.data["trinket"] = "parasitic_vine"
	var option_data := _make_option("obtain_trinket")
	var main_game := _make_main_game()
	var script := EventOptionScriptObtainTrinket.new()

	script.prepare(event_data, main_game, option_data)
	var result: TrinketData = await script.run(option_data, main_game)

	assert_eq(option_data.data["trinket"], "parasitic_vine")
	assert_eq(result, MainDatabase.trinket_database.get_data_by_id("parasitic_vine"))

func test_exit_script_returns_null():
	var option_data := _make_option("exit")
	var main_game := _make_main_game()
	var script := EventOptionScriptExit.new()

	var result = await script.run(option_data, main_game)

	assert_null(result)

func test_gold_cost_options_are_disabled_when_gold_is_too_low():
	var option_data := _make_option("hp", {"hp": "2", "gold": "10"})
	var script := EventOptionScriptHP.new()

	assert_true(script.should_enable(option_data, _make_main_game(10)))
	assert_false(script.should_enable(option_data, _make_main_game(9)))

func test_max_hp_gold_cost_is_disabled_when_gold_is_too_low():
	var option_data := _make_option("max_hp", {"max_hp": "1", "gold": "10"})
	var script := EventOptionScriptMaxHP.new()

	assert_true(script.should_enable(option_data, _make_main_game(10)))
	assert_false(script.should_enable(option_data, _make_main_game(9)))

func test_obtain_card_gold_cost_is_disabled_when_gold_is_too_low():
	var option_data := _make_option("obtain_card", {"card": "runoff", "gold": "8"})
	var script := EventOptionScriptObtainCard.new()

	assert_true(script.should_enable(option_data, _make_main_game(8)))
	assert_false(script.should_enable(option_data, _make_main_game(7)))

func test_obtain_card_hp_cost_is_disabled_when_hp_is_too_low():
	var option_data := _make_option("obtain_card", {"card": "runoff", "hp": "2"})
	var script := EventOptionScriptObtainCard.new()

	assert_true(script.should_enable(option_data, _make_main_game(99, 2)))
	assert_false(script.should_enable(option_data, _make_main_game(99, 1)))

func test_enchant_cost_options_are_disabled_when_resources_are_too_low():
	var gold_option := _make_option("enchant", {"enchant": "free_move", "gold": "10"})
	var hp_option := _make_option("enchant", {"enchant": "free_move", "hp": "2"})
	var script := EventOptionScriptEnchant.new()

	assert_true(script.should_enable(gold_option, _make_main_game(10)))
	assert_false(script.should_enable(gold_option, _make_main_game(9)))
	assert_true(script.should_enable(hp_option, _make_main_game(99, 2)))
	assert_false(script.should_enable(hp_option, _make_main_game(99, 1)))

func test_remove_card_cost_options_are_disabled_when_resources_are_too_low():
	var gold_option := _make_option("remove_card", {"gold": "10"})
	var hp_option := _make_option("remove_card", {"hp": "2"})
	var script := EventOptionScriptRemoveCard.new()

	assert_true(script.should_enable(gold_option, _make_main_game(10)))
	assert_false(script.should_enable(gold_option, _make_main_game(9)))
	assert_true(script.should_enable(hp_option, _make_main_game(99, 2)))
	assert_false(script.should_enable(hp_option, _make_main_game(99, 1)))
