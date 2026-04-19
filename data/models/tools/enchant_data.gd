class_name EnchantData
extends ThingData

const COSTS := {
	0: 15,  # common
	1: 30,  # uncommon
}

@export var action_data:ActionData
@export var rarity:int = 0

var cost:int: get = _get_cost

func _get_cost() -> int:
	return COSTS.get(rarity, 0)

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_enchant: EnchantData = other as EnchantData
	action_data = other_enchant.action_data.get_duplicate()
	rarity = other_enchant.rarity

func get_duplicate() -> EnchantData:
	var dup:EnchantData = EnchantData.new()
	dup.copy(self)
	return dup

func _get_localization_prefix() -> String:
	return "ENCHANT_"
