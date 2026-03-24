extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketSporeGlass:
	var t := PlayerTrinketSporeGlass.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"draw"] = "1"
	t.data = td
	return t

# ----- has_hand_size_hook -----

func test_has_hand_size_hook_false_when_no_plants() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.plant_field_container = PlantFieldContainer.new()
	assert_false(t.has_hand_size_hook(cm))

# ----- other hooks absent -----

func test_has_no_start_turn_hook() -> void:
	assert_false(_make_trinket().has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	assert_false(_make_trinket().has_end_turn_hook(null))

func test_has_no_draw_hook() -> void:
	assert_false(_make_trinket().has_draw_hook(null, []))

func test_has_no_discard_hook() -> void:
	assert_false(_make_trinket().has_discard_hook(null, []))

func test_has_no_exhaust_hook() -> void:
	assert_false(_make_trinket().has_exhaust_hook(null, []))
