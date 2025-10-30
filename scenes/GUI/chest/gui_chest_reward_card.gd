class_name GUIChestRewardCard
extends GUIChestRewardItem

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

func update_with_data(data:ToolData) -> void:
	gui_tool_card_button.update_with_tool_data(data)
