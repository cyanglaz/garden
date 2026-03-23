extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketSecondWindChime:
	var t := PlayerTrinketSecondWindChime.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"threshold"] = "10"
	td.data[&"energy"] = "1"
	t.data = td
	return t

# ----- has_tool_application_hook -----

func test_has_tool_application_hook_always_true() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	assert_true(t.has_tool_application_hook(cm, null))

func test_has_tool_application_hook_true_when_stack_is_9() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	(t.data as TrinketData).stack = 9
	assert_true(t.has_tool_application_hook(cm, null))

func test_has_tool_application_hook_true_when_stack_is_10() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	(t.data as TrinketData).stack = 10
	assert_true(t.has_tool_application_hook(cm, null))

# ----- other hooks absent -----

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))

func test_has_no_draw_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_draw_hook(null, []))

func test_has_no_discard_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_discard_hook(null, []))
