class_name GUIToolShopButton
extends GUIShopButton

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

func update_with_tool_data(tool_data:ToolData) -> void:
	gui_tool_card_button.update_with_tool_data(tool_data)
	cost = tool_data.cost
