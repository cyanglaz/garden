class_name GUIAttackCountIcon
extends HBoxContainer

const COUNT_STRING := "Display %s symbols at once."
const VALUE_COLOR := Constants.COLOR_RED2

@export var tooltip_position :GUITooltip.TooltipPosition

@onready var label: Label = %Label

var _weak_tooltip:WeakRef = weakref(null)
var _count:int

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_default_cursor_shape = Control.CursorShape.CURSOR_HELP

func update_with_attack_count(count:int) -> void:
	_count = count
	label.text = str(count)

func on_mouse_entered() -> void:
	var count_text := Util.convert_to_bbc_highlight_text(str(_count), Constants.TOOLTIP_HIGHLIGHT_COLOR_RED)
	_weak_tooltip = weakref(Util.display_rich_text_tooltip(COUNT_STRING%count_text, self, true, tooltip_position))
