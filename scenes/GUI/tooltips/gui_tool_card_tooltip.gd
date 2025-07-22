class_name GUIToolCardTooltip
extends GUITooltip

@onready var gui_tool_card_description: GUIToolCardDescription = %GUIToolCardDescription

func update_with_tool_data(tool_data:ToolData) -> void:
	gui_tool_card_description.update_with_tool_data(tool_data)
