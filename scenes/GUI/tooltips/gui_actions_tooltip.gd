class_name GUIActionsTooltip
extends GUITooltip

@onready var _gui_actions_description: GUIActionsDescription = %GUIActionsDescription

func _update_with_data() -> void:
	if _data is ToolData.Special:
		_gui_actions_description.update_with_special(_data as ToolData.Special)
	elif _data is Array[ActionData]:
		_gui_actions_description.update_with_actions(_data as Array[ActionData], null)
	else:
		push_error("Invalid data type for actions tooltip")

func get_action_description(index:int) -> String:
	var one_action_description:GUIOneActionDescription = _gui_actions_description.get_child(index)
	return one_action_description.rich_text_label.text