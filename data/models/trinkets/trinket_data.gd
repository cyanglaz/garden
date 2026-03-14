class_name TrinketData
extends ThingData

@export var rarity:int = 0 #0: common, 1: uncommon, 2: rare

var stack:int: set = _set_stack

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_trinket_data := other as TrinketData
	rarity = other_trinket_data.rarity
	stack = other_trinket_data.stack

func get_duplicate() -> TrinketData:
	var dup:TrinketData = TrinketData.new()
	dup.copy(self)
	return dup

func _get_localization_prefix() -> String:
	return "TRINKET_"

func _set_stack(value:int) -> void:
	stack = value
	data["stack"] = str(value)
