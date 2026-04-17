class_name EnchantData
extends ThingData

@export var action_data:ActionData
@export var rarity:int = 0

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
