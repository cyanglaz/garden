class_name EnchantData
extends ThingData

const COSTS := {
	-1: 0,  # temp cards
	0: 15,  # common
	1: 30,  # uncommon
	2: 62,
}

@export var action_data:ActionData
@export var rarity:int = 0

var cost:int: get = _get_cost

func _get_cost() -> int:
	assert(rarity >= -1 && rarity <= 2, "Rarity is out of range")
	return COSTS.get(rarity, 0)

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_enchant: EnchantData = other as EnchantData
	assert(other_enchant.action_data != null, "Action data is null")
	action_data = other_enchant.action_data.get_duplicate()
	rarity = other_enchant.rarity

func get_duplicate() -> EnchantData:
	var dup:EnchantData = EnchantData.new()
	dup.copy(self)
	return dup

func _get_localization_prefix() -> String:
	return "ENCHANT_"
