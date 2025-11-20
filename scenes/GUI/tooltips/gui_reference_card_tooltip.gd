class_name GUIReferenceCardTooltip
extends GUITooltip

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

func _ready() -> void:
	super._ready()
	scale = Vector2(0.9, 0.9)
	gui_tool_card_button.card_state = GUIToolCardButton.CardState.HIGHLIGHTED
	gui_tool_card_button.resource_sufficient = true
	
func _update_with_data() -> void:
	gui_tool_card_button.update_with_tool_data(_data)
