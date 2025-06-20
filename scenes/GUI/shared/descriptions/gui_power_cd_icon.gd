class_name GUIPowerCDIcon
extends HBoxContainer

@onready var _label: Label = %Label
var tooltip_position:GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.BOTTOM

var _weak_tooltip:WeakRef = weakref(null)
var _cd:int

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_default_cursor_shape = Control.CursorShape.CURSOR_HELP

func update_with_cd(cd:int) -> void:
	_cd = cd
	_label.text = str(cd)

func _on_mouse_entered() -> void:
	var text := tr("POWER_CD_TOOLTIP") % str(_cd)
	_weak_tooltip = weakref(Util.display_rich_text_tooltip(text, self, true, tooltip_position))
