extends GutTest

# Tests for CombatModifierManager.
# Only tests methods that do NOT require CombatMain:
#   add_modifier() with LEVEL timing, clear_for_level/turn(),
#   remove_modifier(), card_use_limit().

func _make_modifier(
	type: CombatModifier.ModifierType = CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE,
	timing: CombatModifier.ModifierTiming = CombatModifier.ModifierTiming.LEVEL,
	value: int = 1
) -> CombatModifier:
	var cm := CombatModifier.new()
	cm.modifier_type = type
	cm.modifier_timing = timing
	cm.modifier_value = value
	return cm

func _make_manager() -> CombatModifierManager:
	return CombatModifierManager.new()

# ----- add_modifier (LEVEL timing — safe, does not call _apply_modifier) -----

func test_add_level_modifier_appears_in_array():
	var mgr := _make_manager()
	var cm := _make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL)
	mgr.add_modifier(cm)
	assert_eq(mgr.modifiers.size(), 1)
	assert_true(cm in mgr.modifiers)

func test_add_multiple_level_modifiers():
	var mgr := _make_manager()
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL))
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_USE_LIMIT, CombatModifier.ModifierTiming.LEVEL))
	assert_eq(mgr.modifiers.size(), 2)

# ----- remove_modifier -----

func test_remove_modifier_reduces_count():
	var mgr := _make_manager()
	var cm := _make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL)
	mgr.add_modifier(cm)
	mgr.remove_modifier(cm)
	assert_eq(mgr.modifiers.size(), 0)

func test_remove_modifier_removes_correct_one():
	var mgr := _make_manager()
	var cm1 := _make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL)
	var cm2 := _make_modifier(CombatModifier.ModifierType.CARD_USE_LIMIT, CombatModifier.ModifierTiming.LEVEL)
	mgr.add_modifier(cm1)
	mgr.add_modifier(cm2)
	mgr.remove_modifier(cm1)
	assert_eq(mgr.modifiers.size(), 1)
	assert_true(cm2 in mgr.modifiers)
	assert_false(cm1 in mgr.modifiers)

func test_remove_nonexistent_modifier_does_not_crash():
	var mgr := _make_manager()
	var cm := _make_modifier()
	mgr.remove_modifier(cm)  # should not crash
	assert_eq(mgr.modifiers.size(), 0)

# ----- clear_for_level -----

func test_clear_for_level_removes_level_modifiers():
	var mgr := _make_manager()
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL))
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL))
	mgr.clear_for_level()
	assert_eq(mgr.modifiers.size(), 0)

func test_clear_for_level_keeps_turn_modifiers():
	var mgr := _make_manager()
	var turn_mod := _make_modifier(CombatModifier.ModifierType.CARD_USE_LIMIT, CombatModifier.ModifierTiming.TURN)
	# Manually append TURN modifier to avoid triggering _apply_modifier
	mgr.modifiers.append(turn_mod)
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL))
	mgr.clear_for_level()
	assert_eq(mgr.modifiers.size(), 1)
	assert_true(turn_mod in mgr.modifiers)

# ----- clear_for_turn -----

func test_clear_for_turn_removes_turn_modifiers():
	var mgr := _make_manager()
	var turn_mod := _make_modifier(CombatModifier.ModifierType.CARD_USE_LIMIT, CombatModifier.ModifierTiming.TURN)
	mgr.modifiers.append(turn_mod)
	mgr.clear_for_turn()
	assert_eq(mgr.modifiers.size(), 0)

func test_clear_for_turn_keeps_level_modifiers():
	var mgr := _make_manager()
	var level_mod := _make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL)
	mgr.add_modifier(level_mod)
	mgr.modifiers.append(_make_modifier(CombatModifier.ModifierType.CARD_USE_LIMIT, CombatModifier.ModifierTiming.TURN))
	mgr.clear_for_turn()
	assert_eq(mgr.modifiers.size(), 1)
	assert_true(level_mod in mgr.modifiers)

# ----- card_use_limit -----

func test_card_use_limit_no_modifiers_returns_large_number():
	var mgr := _make_manager()
	assert_eq(mgr.card_use_limit(), 99999999)

func test_card_use_limit_one_modifier_returns_its_value():
	var mgr := _make_manager()
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_USE_LIMIT, CombatModifier.ModifierTiming.LEVEL, 3))
	assert_eq(mgr.card_use_limit(), 3)

func test_card_use_limit_returns_minimum_of_two():
	var mgr := _make_manager()
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_USE_LIMIT, CombatModifier.ModifierTiming.LEVEL, 5))
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_USE_LIMIT, CombatModifier.ModifierTiming.LEVEL, 2))
	assert_eq(mgr.card_use_limit(), 2)

func test_card_use_limit_ignores_non_limit_modifiers():
	var mgr := _make_manager()
	mgr.add_modifier(_make_modifier(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, CombatModifier.ModifierTiming.LEVEL, 10))
	# No CARD_USE_LIMIT modifier, so returns large sentinel
	assert_eq(mgr.card_use_limit(), 99999999)
