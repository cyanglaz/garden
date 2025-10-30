class_name CombatModifierManager
extends RefCounted

var modifiers:Array[CombatModifier] = []

var _combat_main:CombatMain: set = _set_combat_main, get = _get_combat_main
var _weak_combat_main:WeakRef = weakref(null)

func setup(combat_main:CombatMain) -> void:
	_combat_main = combat_main

func add_modifier(modifier:CombatModifier) -> void:
	modifiers.append(modifier)
	if modifier.modifier_timing == CombatModifier.ModifierTiming.TURN:
		_apply_modifier(modifier)

func clear_for_level() -> void:
	modifiers = modifiers.filter(func(modifier:CombatModifier) -> bool:
		return modifier.modifier_timing != CombatModifier.ModifierTiming.LEVEL
	)

func clear_for_turn() -> void:
	modifiers = modifiers.filter(func(modifier:CombatModifier) -> bool:
		return modifier.modifier_timing != CombatModifier.ModifierTiming.TURN
	)

func remove_modifier(modifier:CombatModifier) -> void:
	modifiers.erase(modifier)

func apply_modifiers(timing:CombatModifier.ModifierTiming) -> void:
	var modifiers_to_apply:Array[CombatModifier] = modifiers.filter(func(modifier:CombatModifier) -> bool:
		return modifier.modifier_timing == timing
	)
	for modifier in modifiers_to_apply:
		_apply_modifier(modifier)

func _apply_modifier(modifier:CombatModifier) -> void:
	match modifier.modifier_type:
		CombatModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE:
			_apply_card_energy_cost_additive_modifier(modifier)
		CombatModifier.ModifierType.CARD_ENERGY_COST_MULTIPLICATIVE:
			_apply_card_energy_cost_multiplicative_modifier(modifier)
		CombatModifier.ModifierType.CARD_USE_LIMIT:
			pass # Handled by `func card_use_limit()`

func card_use_limit() -> int:
	var card_limit_modifiers:Array = modifiers.filter(func(modifier:CombatModifier) -> bool:
		return modifier.modifier_type == CombatModifier.ModifierType.CARD_USE_LIMIT
	)
	var card_limit_value:int = 99999999
	for card_limit_modifier:CombatModifier in card_limit_modifiers:
		assert(card_limit_modifier.modifier_value > 0)
		card_limit_value = min(card_limit_value, card_limit_modifier.modifier_value)
	return card_limit_value

func _apply_card_energy_cost_additive_modifier(modifier:CombatModifier) -> void:
	for tool_data in _combat_main.tool_manager.tool_deck.hand:
		if modifier.modifier_value > 0:
			tool_data.energy_modifier += modifier.modifier_value
	_combat_main.tool_manager.refresh_ui()

func _apply_card_energy_cost_multiplicative_modifier(modifier:CombatModifier) -> void:
	for tool_data in _combat_main.tool_manager.tool_deck.hand:
		if modifier.modifier_value > 0:
			tool_data.turn_energy_modifier += tool_data.energy_cost * (modifier.modifier_value-1)
	_combat_main.tool_manager.refresh_ui()

func _set_combat_main(val:CombatMain) -> void:
	_weak_combat_main = weakref(val)

func _get_combat_main() -> CombatMain:
	return _weak_combat_main.get_ref()
