extends GutTest

class FakeFieldStatusContainerFungus extends FieldStatusContainer:
	var fungus_stack: int = 0
	func get_status_stack(status_id: String) -> int:
		if status_id == "fungus":
			return fungus_stack
		return 0

class FakePlantSpore extends Plant:
	pass

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
	var plant_field_container := PlantFieldContainer.new()
	autofree(plant_field_container)
	cm.plant_field_container = plant_field_container
	assert_false(t.has_hand_size_hook(cm))

func test_handle_hand_size_hook_emits_hook_animation_signal() -> void:
	var t := _make_trinket()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	var cm := FakeCombatMain.new()
	autofree(cm)
	var pfc := PlantFieldContainer.new()
	autofree(pfc)
	var fp := FakePlantSpore.new()
	autofree(fp)
	var fsc := FakeFieldStatusContainerFungus.new()
	autofree(fsc)
	fsc.fungus_stack = 1
	fp.field_status_container = fsc
	pfc.plants.append(fp)
	cm.plant_field_container = pfc
	var bonus := t._handle_hand_size_hook(cm)
	assert_true(saw_anim[0])
	assert_eq(bonus, int(t.data.data[&"draw"]))

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
