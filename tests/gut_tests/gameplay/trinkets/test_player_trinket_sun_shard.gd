extends GutTest

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket(light_value: int = 3) -> PlayerTrinketSunShard:
	var t := PlayerTrinketSunShard.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data["light"] = light_value
	t.data = td
	return t

func _make_combat_main(field_index: int, max_idx: int) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	var psc := PlayerStatusContainer.new()
	autofree(psc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = psc
	p.max_plants_index = max_idx
	p.current_field_index = field_index
	cm.player = p
	return cm

# ----- has_end_turn_hook -----

func test_has_hook_true_at_index_zero() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0, 3)
	assert_true(t.has_end_turn_hook(cm))

func test_has_hook_true_at_max_index() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(3, 3)
	assert_true(t.has_end_turn_hook(cm))

func test_has_hook_false_at_middle_index() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(1, 3)
	assert_false(t.has_end_turn_hook(cm))

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))
