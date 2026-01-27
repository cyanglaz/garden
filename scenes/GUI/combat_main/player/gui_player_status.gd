class_name GUIPlayerStatus
extends PanelContainer

const ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var stack: Label = %Stack

func update_with_player_status_data(player_status_data:StatusData) -> void:
	gui_icon.texture = load(ICON_PREFIX % player_status_data.id)
	stack.text = str(player_status_data.stack)
