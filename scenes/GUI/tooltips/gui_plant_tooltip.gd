class_name GUIPlantTooltip
extends GUITooltip

@onready var _gui_plant_description: GUIPlantDescription = %GUIPlantDescription

var library_mode := false
var _weak_plant_data:WeakRef = weakref(null)
var _weak_show_library_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tooltop_shown)

func update_with_plant_data(plant_data:PlantData) -> void:
	_weak_plant_data = weakref(plant_data)
	_gui_plant_description.update_with_plant_data(plant_data)

func _on_tooltop_shown() -> void:
	if library_mode:
		return
	await Util.create_scaled_timer(Constants.SECONDARY_TOOLTIP_DELAY).timeout
	_weak_show_library_tooltip = weakref(Util.display_show_library_tooltip(_weak_plant_data.get_ref(), self, false, GUITooltip.TooltipPosition.BOTTOM_LEFT))

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _weak_show_library_tooltip.get_ref():
			_weak_show_library_tooltip.get_ref().queue_free()
			_weak_show_library_tooltip = weakref(null)
