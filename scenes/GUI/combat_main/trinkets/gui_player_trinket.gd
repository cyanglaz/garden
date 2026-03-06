class_name GUIPlayerTrinket
extends PanelContainer

const ICON_PREFIX := "res://resources/sprites/GUI/icons/trinkets/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var stack: Label = %Stack

func update_with_trinket_data(trinket_data:TrinketData) -> void:
	gui_icon.texture = load(ICON_PREFIX % trinket_data.id)
	if trinket_data.stack > 0:
		stack.text = str(trinket_data.stack)
	else:
		stack.text = ""
