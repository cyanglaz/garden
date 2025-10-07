class_name GameModifier
extends ThingData

enum ModifierTiming {
	LEVEL,
	TURN,
}

enum ModifierType {
	CARD_ENERGY_COST_ADDITIVE,
	CARD_ENERGY_COST_MULTIPLICATIVE,
	CARD_USE_LIMIT,
}

var modifier_type:ModifierType
var modifier_timing:ModifierTiming
var modifier_value:int = 0

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_game_modifier: GameModifier = other as GameModifier
	modifier_type = other_game_modifier.modifier_type
	modifier_timing = other_game_modifier.modifier_timing
	modifier_value = other_game_modifier.modifier_value

func get_duplicate() -> GameModifier:
	var dup:GameModifier = GameModifier.new()
	dup.copy(self)
	return dup
