class_name GUICardTooltip
extends GUITooltip

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

var _weak_tool_data:WeakRef = weakref(null)
var _weak_tool_card_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tool_tip_shown)

func update_with_tool_data(tool_data:ToolData) -> void:
	_weak_tool_data = weakref(tool_data)
	gui_tool_card_button.update_with_tool_data(tool_data)
	gui_tool_card_button.display_mode = true

func _on_tool_tip_shown() -> void:
	await Util.create_scaled_timer(Constants.SECONDARY_TOOLTIP_DELAY).timeout
	_weak_tool_card_tooltip = weakref(Util.display_tool_card_tooltip(_weak_tool_data.get_ref(), self, false, self.tooltip_position, true))

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _weak_tool_card_tooltip.get_ref():
			_weak_tool_card_tooltip.get_ref().queue_free()
			_weak_tool_card_tooltip = weakref(null)
