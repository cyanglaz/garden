extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketFermentationFlask:
	var t := PlayerTrinketFermentationFlask.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"discard_count"] = "3"
	td.data[&"light"] = "2"
	td.data[&"water"] = "2"
	t.data = td
	return t

# ----- has_discard_hook -----

func test_has_discard_hook_always_true() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	assert_true(t.has_discard_hook(cm, []))

# ----- has_start_turn_hook -----

func test_has_start_turn_hook_always_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_start_turn_hook(null))

# ----- stack increments and resets -----

func test_stack_increments_below_threshold() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	t._handle_discard_hook(cm, [null, null])
	assert_eq((t.data as TrinketData).stack, 2)

func test_stack_accumulates_across_calls() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	t._handle_discard_hook(cm, [null])
	t._handle_discard_hook(cm, [null])
	assert_eq((t.data as TrinketData).stack, 2)

func test_stack_resets_on_start_turn() -> void:
	var t := _make_trinket()
	(t.data as TrinketData).stack = 2
	t._handle_start_turn_hook(null)
	assert_eq((t.data as TrinketData).stack, 0)

# ----- other hooks absent -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))

func test_has_no_draw_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_draw_hook(null, []))

func test_has_no_tool_application_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_tool_application_hook(null, null))
