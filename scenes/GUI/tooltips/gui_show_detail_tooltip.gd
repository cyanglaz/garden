class_name GUIShowDetailTooltip
extends GUITooltip

const INPUT_ICON_PATH := "res://resources/sprites/GUI/icons/inputs/input_v.png"

@onready var description: RichTextLabel = %Description

var _weak_data:WeakRef = weakref(null)

func update_with_data(data:ThingData) -> void:
	_weak_data = weakref(data)
	var input_icon_string := str("[img=6x6]", INPUT_ICON_PATH, "[/img]")
	var highlight_name := str("[outline_size=1][color=%s]", data.display_name, "[/color][/outline_size]")%[Util.get_color_hex(Constants.COLOR_WHITE)]
	description.text = Util.get_localized_string("SHOW_LIBRARY_TOOLTIP_PROMPT") % [input_icon_string, highlight_name]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("library"):
		Singletons.main_game.show_thing_info_view(_weak_data.get_ref())
		
