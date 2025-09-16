class_name GUIThingDataTooltip
extends GUITooltip

@onready var gui_thing_data_description: GUIThingDataDescription = %GUIThingDataDescription

var library_tooltip_position := GUITooltip.TooltipPosition.BOTTOM_RIGHT
var library_mode := false
var _weak_show_library_tooltip:WeakRef = weakref(null)
var _weak_thing_data:WeakRef = weakref(null)

func update_with_thing_data(thing_data:ThingData) -> void:
	_weak_thing_data = weakref(thing_data)
	gui_thing_data_description.update_with_thing_data(thing_data)

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tooltop_shown)

func _on_tooltop_shown() -> void:
	if library_mode:
		return
	await Util.create_scaled_timer(Constants.SECONDARY_TOOLTIP_DELAY).timeout
	_weak_show_library_tooltip = weakref(Util.display_show_library_tooltip(_weak_thing_data.get_ref(), self, false, library_tooltip_position))

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _weak_show_library_tooltip.get_ref():
			_weak_show_library_tooltip.get_ref().queue_free()
			_weak_show_library_tooltip = weakref(null)
