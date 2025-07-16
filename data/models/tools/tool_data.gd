class_name ToolData
extends ThingData

@export var energy_cost:int = 1
@export var actions:Array[ActionData]

var need_select_field:bool : get = _get_need_select_field

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_tool: ToolData = other as ToolData
	energy_cost = other_tool.energy_cost
	actions = other_tool.actions.duplicate()

func get_duplicate() -> ToolData:
	var dup:ToolData = ToolData.new()
	dup.copy(self)
	return dup

func _get_need_select_field() -> bool:
	for action_data:ActionData in actions:
		if action_data.action_category == ActionData.ActionCategory.FIELD:
			return true
	return false
