class_name GUIReferenceCardTooltip
extends GUITooltip

const SCALE := 0.7

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

func _ready() -> void:
	super._ready()
	gui_tool_card_button.scale = Vector2.ONE * SCALE

func update_with_data(data:Variant) -> void:
	gui_tool_card_button.update_with_tool_data(data)
