class_name GUIToolCardTooltip
extends GUITooltip

@onready var gui_actions_description: GUIActionsDescription = %GUIActionsDescription
@onready var gui_tool_special_description: GUIToolSpecialDescription = %GUIToolSpecialDescription

func _update_with_data() -> void:
	var tool_data:ToolData = _data as ToolData
	if tool_data.actions.is_empty():
		gui_actions_description.hide()
	else:
		gui_actions_description.show()
		gui_actions_description.update_with_actions(tool_data.actions, null)
	if tool_data.specials.is_empty():
		gui_tool_special_description.hide()


