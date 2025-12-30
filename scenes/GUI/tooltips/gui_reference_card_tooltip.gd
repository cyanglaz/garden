class_name GUIReferenceCardTooltip
extends GUITooltip

const SCALE := 0.95

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

func _ready() -> void:
	super._ready()
	scale = Vector2(SCALE, SCALE)
	gui_tool_card_button.card_state = GUICardFace.CardState.HIGHLIGHTED
	
func _update_with_tooltip_request() -> void:
	gui_tool_card_button.update_with_tool_data(_tooltip_request.data)
