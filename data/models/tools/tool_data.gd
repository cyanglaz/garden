class_name ToolData
extends ThingData

@export var time:int = 1
@export var actions:Array[ActionData]

func copy(other:ThingData) -> void:
	var other_tool: ToolData = other as ToolData
	time = other_tool.time
	actions = other_tool.actions.duplicate()

func get_duplicate() -> ToolData:
	var dup:ToolData = ToolData.new()
	dup.copy(self)
	return dup

func get_display_description() -> String:
	var formatted_description := description
	formatted_description = _formate_references(formatted_description, data, func(_reference_id:String) -> bool:
		return false
	)
	return formatted_description
