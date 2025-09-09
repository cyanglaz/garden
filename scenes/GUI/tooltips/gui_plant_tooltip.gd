class_name GUIPlantTooltip
extends GUITooltip

@onready var _gui_plant_description: GUIPlantDescription = %GUIPlantDescription

var card_tooltips:Array[WeakRef] = []
var _weak_plant_data:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	tool_tip_shown.connect(_on_tooltop_shown)

func update_with_plant_data(plant_data:PlantData) -> void:
	_weak_plant_data = weakref(plant_data)
	_gui_plant_description.update_with_plant_data(plant_data)

func _on_tooltop_shown() -> void:
	await Util.create_scaled_timer(Constants.SECONDARY_TOOLTIP_DELAY).timeout
	var tool_ids:Array[String] = Util.find_tool_ids_in_data(_weak_plant_data.get_ref().data)
	for tool_id:String in tool_ids:
		var tool_data := MainDatabase.tool_database.get_data_by_id(tool_id)
		card_tooltips.append(weakref(Util.display_card_tooltip(tool_data, self, false, GUITooltip.TooltipPosition.LEFT)))

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for weak_card_tooltip in card_tooltips:
			if weak_card_tooltip.get_ref():
				weak_card_tooltip.get_ref().queue_free()
				weak_card_tooltip = weakref(null)
