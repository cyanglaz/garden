class_name GUIBossTooltip
extends GUITooltip

const CARD_TOOLTIP_DELAY := 0.2

@onready var name_label: Label = %NameLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var library_mode := true
var _weak_show_library_tooltip:WeakRef = weakref(null)
var _weak_level_data:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tooltop_shown)

func update_with_level_data(level_data:LevelData) -> void:
	_weak_level_data = weakref(level_data)
	name_label.text = level_data.display_name
	rich_text_label.text = level_data.get_display_description()

func _on_tooltop_shown() -> void:
	await Util.create_scaled_timer(CARD_TOOLTIP_DELAY).timeout
	_weak_show_library_tooltip = weakref(Util.display_show_library_tooltip(_weak_level_data.get_ref(), self, false, GUITooltip.TooltipPosition.BOTTOM_LEFT))

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _weak_show_library_tooltip.get_ref():
			_weak_show_library_tooltip.get_ref().queue_free()
			_weak_show_library_tooltip = weakref(null)
