extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketParasiticVine:
	var t := PlayerTrinketParasiticVine.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"max_hp"] = "5"
	td.data[&"hp"] = "1"
	t.data = td
	return t

# ----- has_plant_bloom_hook -----

func test_has_plant_bloom_hook_always_true() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	assert_true(t.has_plant_bloom_hook(cm))

# ----- other hooks absent -----

func test_has_no_draw_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_draw_hook(null, []))

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
