class_name ToolData
extends ThingData

const TOOL_SCRIPT_PATH := "res://scenes/main_game/tool/tool_scripts/tool_script_%s.gd"

const COSTS := {
	0: 10,
	1: 25,
	2: 45,
}

enum Special {
	ALL_FIELDS,
}

@export var energy_cost:int = 1
@export var actions:Array[ActionData]
@export var rarity:int = 0
@export var specials:Array[Special]
@export var need_select_field:bool

var cost:int : get = _get_cost
var is_all_fields:bool : get = _get_is_all_fields
var tool_script:ToolScript : get = _get_tool_script


func copy(other:ThingData) -> void:
	super.copy(other)
	var other_tool: ToolData = other as ToolData
	energy_cost = other_tool.energy_cost
	actions = other_tool.actions.duplicate()
	rarity = other_tool.rarity
	specials = other_tool.specials.duplicate()
	need_select_field = other_tool.need_select_field

func get_duplicate() -> ToolData:
	var dup:ToolData = ToolData.new()
	dup.copy(self)
	return dup

func _get_cost() -> int:
	return COSTS[rarity]

func _get_is_all_fields() -> bool:
	return specials.has(Special.ALL_FIELDS)

func _get_tool_script() -> ToolScript:
	var script_path := TOOL_SCRIPT_PATH % [id]
	if ResourceLoader.exists(script_path):
		return load(script_path).new()
	else:
		return null
	
