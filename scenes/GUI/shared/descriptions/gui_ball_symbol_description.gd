class_name GUIBallSymbolDescription
extends VBoxContainer

const MAIN_COLOR := Constants.COLOR_BROWN_3
const VALUE_COLOR := Constants.COLOR_BLUE_5

const ROW_STRING := "Placed on row: "
const COL_STRING := "Placed on column: "
const CORNER_STRING := "Placed on corners"
const PRIORITIZE_CORNER_STRING := "Placed on corner spaces if available"
const PRIORITIZE_EDGE_STRING := "Placed on edge spaces if available"
const PRIORITIZE_CENTER_STRING := "Placed on center space if available"
const PRIORITIZE_BOTTOM_STRING := "Placed on lowest available row"
const PRIORITIZE_TOP_STRING := "Placed on highest available row"
const PRIORITIZE_LEFT_STRING := "Placed on leftmost available column"
const PRIORITIZE_RIGHT_STRING := "Placed on rightmost available column"
 
@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func setup_with_placement_rule(placement_rule:BingoBallData.PlacementRule, values:Array) -> void:
	var text := ""
	match placement_rule:
		BingoBallData.PlacementRule.ROW:
			text = ROW_STRING
		BingoBallData.PlacementRule.COLUMN:
			text = COL_STRING
		BingoBallData.PlacementRule.CORNER:
			text = CORNER_STRING
		BingoBallData.PlacementRule.PRIORITIZE_BOTTOM:
			text = PRIORITIZE_BOTTOM_STRING
		BingoBallData.PlacementRule.PRIORITIZE_TOP:
			text = PRIORITIZE_TOP_STRING
		BingoBallData.PlacementRule.PRIORITIZE_CORNER:
			text = PRIORITIZE_CORNER_STRING
		BingoBallData.PlacementRule.PRIORITIZE_EDGE:
			text = PRIORITIZE_EDGE_STRING
		BingoBallData.PlacementRule.PRIORITIZE_CENTER:
			text = PRIORITIZE_CENTER_STRING
		BingoBallData.PlacementRule.PRIORITIZE_LEFT:
			text = PRIORITIZE_LEFT_STRING
		BingoBallData.PlacementRule.PRIORITIZE_RIGHT:
			text = PRIORITIZE_RIGHT_STRING
		_:
			assert(false, "Invalid placement rule: %s" % placement_rule)
	var index := 0
	for value in values:
		var value_text := "[color=%s]%s[/color]" % [Util.get_color_hex(VALUE_COLOR), str(value + 1)]
		if index < values.size() - 1:
			text += value_text + ", "
		else:
			text += value_text
		index += 1
	text += "."
	_rich_text_label.text = "[color=%s]%s[/color]" % [Util.get_color_hex(MAIN_COLOR), text]
