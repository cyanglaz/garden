class_name GUIShopGoldIcon
extends PanelContainer

@onready var gold_highlight_border: NinePatchRect = %GoldHighlightBorder

var highlighted := false: set = _set_highlighted

func _ready() -> void:
	highlighted = false

func _set_highlighted(val:bool) -> void:
	highlighted = val
	gold_highlight_border.visible = val
