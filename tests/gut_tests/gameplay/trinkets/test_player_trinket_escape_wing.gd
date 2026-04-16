extends GutTest

class FakePlayerStatusContainerDamage extends PlayerStatusContainer:
	func update_player_upgrade(_id: String, _stack: int, _operator_type: ActionData.OperatorType) -> void:
		pass

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketEscapeWing:
	var t := PlayerTrinketEscapeWing.new()
	add_child_autofree(t)
	t.data = TrinketData.new()
	return t

# ----- has_damage_taken_hook -----


func test_has_damage_taken_hook_true_before_triggered() -> void:
	assert_true(_make_trinket().has_damage_taken_hook(null, 1))

func test_has_damage_taken_hook_false_after_triggered() -> void:
	var t := _make_trinket()
	t._triggered = true
	assert_false(t.has_damage_taken_hook(null, 1))

# ----- start_turn_hook (day 0 only) -----

func test_has_start_turn_hook_true_on_day_zero() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	assert_true(t.has_start_turn_hook(cm))

func test_has_start_turn_hook_false_when_day_not_zero() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 3
	assert_false(t.has_start_turn_hook(cm))

func test_handle_start_turn_hook_sets_active() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	t._handle_start_turn_hook(cm)
	assert_eq(t.data.state, TrinketData.TrinketState.ACTIVE)

# ----- damage_taken_hook (state + hook animation signals) -----

func test_handle_damage_taken_hook_sets_normal_and_emits_animation_signals() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	t.data.id = "escape_wing"
	var anim_ids: Array = []
	var popup_datas: Array = []
	t.request_player_upgrade_hook_animation.connect(func(id: String) -> void: anim_ids.append(id))
	t.request_hook_message_popup.connect(func(td: ThingData) -> void: popup_datas.append(td))
	var cm := FakeCombatMain.new()
	autofree(cm)
	var psc := FakePlayerStatusContainerDamage.new()
	autofree(psc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = psc
	cm.player = p
	t._handle_damage_taken_hook(cm, 1)
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)
	assert_eq(anim_ids.size(), 1)
	assert_eq(anim_ids[0], t.data.id)
	assert_eq(popup_datas.size(), 1)
	assert_true(popup_datas[0] == t.data)

# ----- combat_end_hook -----

func test_has_combat_end_hook_always_true() -> void:
	assert_true(_make_trinket().has_combat_end_hook(null))

func test_handle_combat_end_hook_sets_normal() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	t._handle_combat_end_hook(null)
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)

# ----- other hooks absent -----

func test_has_no_end_turn_hook() -> void:
	assert_false(_make_trinket().has_end_turn_hook(null))

func test_has_no_exhaust_hook() -> void:
	assert_false(_make_trinket().has_exhaust_hook(null, []))

func test_has_no_discard_hook() -> void:
	assert_false(_make_trinket().has_discard_hook(null, []))

func test_has_no_draw_hook() -> void:
	assert_false(_make_trinket().has_draw_hook(null, []))
