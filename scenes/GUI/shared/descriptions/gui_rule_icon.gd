class_name GUIRuleIcon
extends HBoxContainer

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
const ALL_STRING := "Placed on any space"

const ROW_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_row.aseprite")
const COLUMN_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_column.aseprite")
const BOTTOM_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_bottom.aseprite")
const CORNER_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_corner.aseprite")
const EDGE_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_edge.aseprite")
const CENTER_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_center.aseprite")
const TOP_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_top.aseprite")
const LEFT_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_left.aseprite")
const RIGHT_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_right.aseprite")
const ALL_ICON := preload("res://resources/sprites/icons/display_rules/icon_display_rule_all.aseprite")


@export var tooltip_position :GUITooltip.TooltipPosition

@onready var _texture_rect: TextureRect = $TextureRect
@onready var _label: Label = %Label

var _weak_tooltip:WeakRef = weakref(null)
var _placement_rule:BingoBallData.PlacementRule
var _values:Array

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_default_cursor_shape = Control.CursorShape.CURSOR_HELP

func bind_placement_rule(placement_rule:BingoBallData.PlacementRule, values:Array = []) -> void:
	var value_index := 0
	_values = values.duplicate()
	for value in values:
		if value_index != 0:
			_label.text += ","
		_label.text += str(value+1)
		value_index += 1
	_placement_rule = placement_rule
	match _placement_rule:
		BingoBallData.PlacementRule.ALL:
			_texture_rect.texture = ALL_ICON
		BingoBallData.PlacementRule.ROW:
			_texture_rect.texture = ROW_ICON
		BingoBallData.PlacementRule.COLUMN:
			_texture_rect.texture = COLUMN_ICON
		BingoBallData.PlacementRule.PRIORITIZE_EDGE:
			_texture_rect.texture = EDGE_ICON
		BingoBallData.PlacementRule.PRIORITIZE_BOTTOM:
			_texture_rect.texture = BOTTOM_ICON
		BingoBallData.PlacementRule.PRIORITIZE_TOP:
			_texture_rect.texture = TOP_ICON
		BingoBallData.PlacementRule.PRIORITIZE_LEFT:
			_texture_rect.texture = LEFT_ICON
		BingoBallData.PlacementRule.PRIORITIZE_RIGHT:
			_texture_rect.texture = RIGHT_ICON
		BingoBallData.PlacementRule.PRIORITIZE_CENTER:
			_texture_rect.texture = CENTER_ICON
		BingoBallData.PlacementRule.PRIORITIZE_CORNER:
			_texture_rect.texture = CORNER_ICON
		_:
			assert(false, "Invalid placement rule: %s" % _placement_rule)

func on_mouse_entered() -> void:
	var text := ""
	match _placement_rule:
		BingoBallData.PlacementRule.ALL:
			text = ALL_STRING
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
			assert(false, "Invalid placement rule: %s" % _placement_rule)
	var index := 0
	for value in _values:
		var value_text := str(value + 1)
		if index < _values.size() - 1:
			text += value_text + ", "
		else:
			text += value_text
		index += 1
	text += "."
	_weak_tooltip = weakref(Util.display_rich_text_tooltip(text, self, true, tooltip_position))
