class_name TrinketData
extends ThingData

const GLOBAL_SCRIPT_PATH := "res://scenes/main_game/trinket/global_scripts/trinket_global_script_%s.gd"

@export var rarity:int = 0 #0: common, 1: uncommon, 2: rare

const COSTS := {
	0: 20,   # common
	1: 38,  # uncommon
	2: 62,  # rare
}

var cost: int: get = _get_cost
var stack:int: set = _set_stack

signal stack_changed(new_value: int)

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_trinket_data := other as TrinketData
	rarity = other_trinket_data.rarity
	stack = other_trinket_data.stack

func get_duplicate() -> TrinketData:
	var dup:TrinketData = TrinketData.new()
	dup.copy(self)
	return dup

func has_global_script() -> bool:
	return ResourceLoader.exists(GLOBAL_SCRIPT_PATH % [id])

func get_global_script() -> TrinketGlobalScript:
	assert(has_global_script(), "Trinket %s has no global script" % [id])
	var path := GLOBAL_SCRIPT_PATH % [id]
	var global_script:TrinketGlobalScript = load(path).new()
	global_script.trinket_data = self
	return global_script

func _get_cost() -> int:
	return COSTS[rarity]

func _get_localization_prefix() -> String:
	return "TRINKET_"

func _set_stack(value:int) -> void:
	stack = value
	data["stack"] = str(value)
	stack_changed.emit(value)
