class_name GUIBallAttackCountDescription
extends RichTextLabel

const MAIN_COLOR := Constants.COLOR_BLUE_GRAY_5
const VALUE_COLOR := Constants.COLOR_RED4

const COUNT_STRING := "Display [color=%s]%s[/color] symbols at once."

func setup_with_count(count:int) -> void:
	var main_string := COUNT_STRING % [Util.get_color_hex(VALUE_COLOR), str(count)]
	text = "[color=%s]%s[/color]" % [Util.get_color_hex(MAIN_COLOR), main_string]
