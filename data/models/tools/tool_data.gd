class_name ToolData
extends ThingData

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

var cost:int : get = _get_cost

var need_select_field:bool : get = _get_need_select_field

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_tool: ToolData = other as ToolData
	energy_cost = other_tool.energy_cost
	actions = other_tool.actions.duplicate()
	rarity = other_tool.rarity
	specials = other_tool.specials.duplicate()

func get_duplicate() -> ToolData:
	var dup:ToolData = ToolData.new()
	dup.copy(self)
	return dup

func _get_need_select_field() -> bool:
	for action_data:ActionData in actions:
		if action_data.action_category == ActionData.ActionCategory.FIELD:
			return true
	return false

func _get_cost() -> int:
	return COSTS[rarity]
