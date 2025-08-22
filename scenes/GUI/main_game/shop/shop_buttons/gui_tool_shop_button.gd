class_name GUIToolShopButton
extends GUIShopButton

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

func update_with_tool_data(tool_data:ToolData) -> void:
	gui_tool_card_button.update_with_tool_data(tool_data)
	gui_tool_card_button.display_mode = true
	cost = tool_data.cost

func _set_highlighted(val:bool) -> void:
	super._set_highlighted(val)
	gui_tool_card_button.highlighted = val

func _get_hover_sound() -> AudioStream:
	return gui_tool_card_button._get_hover_sound()

func _get_click_sound() -> AudioStream:
	return gui_tool_card_button._get_click_sound()

func _set_sufficient_gold(val:bool) -> void:
	super._set_sufficient_gold(val)
	if val:
		gui_tool_card_button.resource_sufficient = true
	else:
		gui_tool_card_button.resource_sufficient = false
