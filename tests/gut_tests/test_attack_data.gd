extends GutTest

# Tests for AttackData – enemy attack configuration.
# Also covers CombatModifier as a related combat data class.

const FAKE_PATH := "res://fake/test_attack.tres"

func _make_attack() -> AttackData:
	var ad := AttackData.new()
	ad.set("_original_resource_path", FAKE_PATH)
	ad.id = "simple_attack"
	ad.attack_type = AttackData.AttackType.SIMPLE
	ad.damage = 5
	ad.target_positions = [0, 1]
	return ad

func _make_modifier() -> CombatModifier:
	var cm := CombatModifier.new()
	cm.set("_original_resource_path", FAKE_PATH)
	cm.id = "modifier_1"
	cm.modifier_type = CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE
	cm.modifier_timing = CombatModifier.ModifierTiming.TURN
	cm.modifier_value = 1
	return cm

# ----- AttackData: copy / get_duplicate -----

func test_attack_duplicate_copies_id():
	var ad := _make_attack()
	ad.id = "heavy_strike"
	var dup := ad.get_duplicate()
	assert_eq(dup.id, "heavy_strike")

func test_attack_duplicate_copies_attack_type():
	var ad := _make_attack()
	ad.attack_type = AttackData.AttackType.SIMPLE
	var dup := ad.get_duplicate()
	assert_eq(dup.attack_type, AttackData.AttackType.SIMPLE)

func test_attack_duplicate_copies_damage():
	var ad := _make_attack()
	ad.damage = 10
	var dup := ad.get_duplicate()
	assert_eq(dup.damage, 10)

func test_attack_duplicate_damage_zero():
	var ad := _make_attack()
	ad.damage = 0
	var dup := ad.get_duplicate()
	assert_eq(dup.damage, 0)

func test_attack_duplicate_copies_target_positions():
	var ad := _make_attack()
	ad.target_positions = [0, 2, 4]
	var dup := ad.get_duplicate()
	assert_eq(dup.target_positions.size(), 3)
	assert_true(0 in dup.target_positions)
	assert_true(2 in dup.target_positions)
	assert_true(4 in dup.target_positions)

func test_attack_duplicate_target_positions_are_independent():
	var ad := _make_attack()
	ad.target_positions = [0, 1]
	var dup := ad.get_duplicate()
	dup.target_positions.append(99)
	assert_eq(ad.target_positions.size(), 2)

func test_attack_duplicate_empty_target_positions():
	var ad := _make_attack()
	ad.target_positions = []
	var dup := ad.get_duplicate()
	assert_eq(dup.target_positions.size(), 0)

# ----- AttackData: enum -----

func test_attack_type_simple_exists():
	assert_eq(AttackData.AttackType.SIMPLE, 0)

# ----- CombatModifier: copy / get_duplicate -----

func test_modifier_duplicate_copies_id():
	var cm := _make_modifier()
	cm.id = "fast_modifier"
	var dup := cm.get_duplicate()
	assert_eq(dup.id, "fast_modifier")

func test_modifier_duplicate_copies_modifier_type():
	var cm := _make_modifier()
	cm.modifier_type = CombatModifier.ModifierType.CARD_ENERGY_COST_MULTIPLICATIVE
	var dup := cm.get_duplicate()
	assert_eq(dup.modifier_type, CombatModifier.ModifierType.CARD_ENERGY_COST_MULTIPLICATIVE)

func test_modifier_duplicate_copies_modifier_timing():
	var cm := _make_modifier()
	cm.modifier_timing = CombatModifier.ModifierTiming.LEVEL
	var dup := cm.get_duplicate()
	assert_eq(dup.modifier_timing, CombatModifier.ModifierTiming.LEVEL)

func test_modifier_duplicate_copies_modifier_value():
	var cm := _make_modifier()
	cm.modifier_value = 3
	var dup := cm.get_duplicate()
	assert_eq(dup.modifier_value, 3)

func test_modifier_duplicate_negative_value():
	var cm := _make_modifier()
	cm.modifier_value = -2
	var dup := cm.get_duplicate()
	assert_eq(dup.modifier_value, -2)

func test_modifier_value_independent():
	var cm := _make_modifier()
	cm.modifier_value = 5
	var dup := cm.get_duplicate()
	dup.modifier_value = 99
	assert_eq(cm.modifier_value, 5)

# ----- CombatModifier: enums -----

func test_modifier_type_enum_has_three_values():
	var types := CombatModifier.ModifierType.values()
	assert_eq(types.size(), 3)

func test_modifier_timing_enum_has_two_values():
	var timings := CombatModifier.ModifierTiming.values()
	assert_eq(timings.size(), 2)

func test_modifier_type_additive():
	assert_eq(CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE, 0)

func test_modifier_timing_level():
	assert_eq(CombatModifier.ModifierTiming.LEVEL, 0)

func test_modifier_timing_turn():
	assert_eq(CombatModifier.ModifierTiming.TURN, 1)
