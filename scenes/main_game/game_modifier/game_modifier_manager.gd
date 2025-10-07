class_name GameModifierManager
extends RefCounted

var modifiers:Array[GameModifier] = []

var _main_game:MainGame: set = _set_main_game, get = _get_main_game
var _weak_main_game:WeakRef = weakref(null)

func setup(main_game:MainGame) -> void:
	_main_game = main_game

func add_modifier(modifier:GameModifier) -> void:
	modifiers.append(modifier)
	if modifier.modifier_timing == GameModifier.ModifierTiming.TURN:
		_apply_modifier(modifier)

func clear_for_level() -> void:
	modifiers = modifiers.filter(func(modifier:GameModifier) -> bool:
		return modifier.modifier_timing != GameModifier.ModifierTiming.LEVEL
	)

func clear_for_turn() -> void:
	modifiers = modifiers.filter(func(modifier:GameModifier) -> bool:
		return modifier.modifier_timing != GameModifier.ModifierTiming.TURN
	)

func remove_modifier(modifier:GameModifier) -> void:
	modifiers.erase(modifier)

func apply_modifiers(timing:GameModifier.ModifierTiming) -> void:
	var modifiers_to_apply:Array[GameModifier] = modifiers.filter(func(modifier:GameModifier) -> bool:
		return modifier.modifier_timing == timing
	)
	for modifier in modifiers_to_apply:
		_apply_modifier(modifier)

func _apply_modifier(modifier:GameModifier) -> void:
	match modifier.modifier_type:
		GameModifier.ModifierType.CARD_ENERGY_COST_ADDITIVE:
			_apply_card_energy_cost_additive_modifier(modifier)
		GameModifier.ModifierType.CARD_ENERGY_COST_MULTIPLICATIVE:
			_apply_card_energy_cost_multiplicative_modifier(modifier)
		GameModifier.ModifierType.CARD_USE_LIMIT:
			pass # Handled by `func card_use_limit()`

func card_use_limit() -> int:
	var card_limit_modifiers:Array = modifiers.filter(func(modifier:GameModifier) -> bool:
		return modifier.modifier_type == GameModifier.ModifierType.CARD_USE_LIMIT
	)
	var card_limit_value:int = 9999999999999999999
	for card_limit_modifier:GameModifier in card_limit_modifiers:
		assert(card_limit_modifier.modifier_value > 0)
		assert(card_limit_modifier.modifier_timing == GameModifier.ModifierTiming.TURN)
		card_limit_value = min(card_limit_value, card_limit_modifier.modifier_value)
	return card_limit_value

func _apply_card_energy_cost_additive_modifier(modifier:GameModifier) -> void:
	for tool_data in _main_game.tool_manager.tool_deck.hand:
		if modifier.modifier_value > 0:
			tool_data.energy_modifier += modifier.modifier_value
	_main_game.tool_manager.refresh_ui()

func _apply_card_energy_cost_multiplicative_modifier(modifier:GameModifier) -> void:
	for tool_data in _main_game.tool_manager.tool_deck.hand:
		if modifier.modifier_value > 0:
			tool_data.energy_modifier += tool_data.energy_cost * (modifier.modifier_value-1)
	_main_game.tool_manager.refresh_ui()

func _set_main_game(val:MainGame) -> void:
	_weak_main_game = weakref(val)

func _get_main_game() -> MainGame:
	return _weak_main_game.get_ref()
