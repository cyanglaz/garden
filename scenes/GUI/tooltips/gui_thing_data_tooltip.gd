class_name GUIThingDataTooltip
extends GUITooltip

@onready var gui_thing_data_description: GUIThingDataDescription = %GUIThingDataDescription

func _update_with_tooltip_request() -> void:
	var thing_data:ThingData = _tooltip_request.data as ThingData
	gui_thing_data_description.update_with_thing_data(thing_data)
