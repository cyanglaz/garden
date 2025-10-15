class_name GUIToolCardTooltip
extends GUITooltip

@onready var gui_actions_description: GUIActionsDescription = %GUIActionsDescription
@onready var gui_tool_special_description: GUIToolSpecialDescription = %GUIToolSpecialDescription

func update_with_tool_data(tool_data:ToolData, target_field:Field) -> void:
	if tool_data.actions.is_empty():
		gui_actions_description.hide()
	else:
		gui_actions_description.show()
		gui_actions_description.update_with_actions(tool_data.actions, target_field)
	if tool_data.specials.is_empty():
		gui_tool_special_description.hide()
	else:
		gui_tool_special_description.show()
		gui_tool_special_description.update_with_specials(tool_data.specials)
