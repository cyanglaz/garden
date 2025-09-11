class_name GUIShowLibraryTooltip
extends GUITooltip

const INPUT_ICON_PATH := "res://resources/sprites/GUI/icons/inputs/input_l.png"

@onready var description: RichTextLabel = %Description

func update_with_data(data:ThingData) -> void:
	var input_icon_string := str("[img=6x6]", INPUT_ICON_PATH, "[/img]")
	var highlight_name := str("[outline_size=1][color=%s]", data.display_name, "[/color][/outline_size]")%[Util.get_color_hex(Constants.COLOR_WHITE)]
	description.text = Util.get_localized_string("SHOW_LIBRARY_TOOLTIP_PROMPT") % [input_icon_string, highlight_name]
