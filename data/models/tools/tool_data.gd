class_name ToolData
extends ThingData

const TOOL_SCRIPT_PATH := "res://scenes/main_game/tool/tool_scripts/tool_script_%s.gd"

@warning_ignore("unused_signal")
signal request_refresh()

const COSTS := {
	0: 6,
	1: 11,
	2: 19,
}

enum Special {
	USE_ON_DRAW,
	COMPOST,
	WITHER,
}


@export var energy_cost:int = 1
@export var actions:Array[ActionData]
@export var rarity:int = 0 # -1: COMPOST, 0: common, 1: uncommon, 2: rare
@export var specials:Array[Special]

var need_select_field:bool : get = _get_need_select_field
var all_fields:bool : get = _get_all_fields
var cost:int : get = _get_cost
var tool_script:ToolScript : get = _get_tool_script

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_tool: ToolData = other as ToolData
	energy_cost = other_tool.energy_cost
	actions.clear()
	for action:ActionData in other_tool.actions:
		actions.append(action.get_duplicate())
	rarity = other_tool.rarity
	specials = other_tool.specials.duplicate()
	need_select_field = other_tool.need_select_field

func get_duplicate() -> ToolData:
	var dup:ToolData = ToolData.new()
	dup.copy(self)
	return dup

func _get_cost() -> int:
	return COSTS[rarity]

func _get_tool_script() -> ToolScript:
	var script_path := TOOL_SCRIPT_PATH % [id]
	if ResourceLoader.exists(script_path):
		return load(script_path).new()
	else:
		return null
	
func _get_need_select_field() -> bool:
	for action:ActionData in actions:
		if action.action_category == ActionData.ActionCategory.FIELD:
			return true
	return false

func _get_all_fields() -> bool:
	for action:ActionData in actions:
		if action.specials.has(ActionData.Special.ALL_FIELDS):
			return true
	return false