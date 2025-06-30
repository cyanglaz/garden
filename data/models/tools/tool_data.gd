class_name ToolData
extends ThingData

@export var cd:int = 1
@export var actions:Array[ActionData]

var cd_counter:int = 0

func copy(other:ThingData) -> void:
	var other_tool: ToolData = other as ToolData
	cd = other_tool.cd
	actions = other_tool.actions.duplicate()
	cd_counter = other_tool.cd_counter

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
