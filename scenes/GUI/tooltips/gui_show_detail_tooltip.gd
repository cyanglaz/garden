class_name GUIShowDetailTooltip
extends GUITooltip

const INPUT_ICON_PATH := "res://resources/sprites/GUI/icons/inputs/input_v.png"

@onready var description: RichTextLabel = %Description

var _weak_data:WeakRef = weakref(null)

func _update_with_data() -> void:
	var input_icon_string := str("[img=6x6]", INPUT_ICON_PATH, "[/img]")
	description.text = Util.get_localized_string("SHOW_LIBRARY_TOOLTIP_PROMPT") % [input_icon_string]