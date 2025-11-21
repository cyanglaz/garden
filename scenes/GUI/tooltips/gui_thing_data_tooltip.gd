class_name GUIThingDataTooltip
extends GUITooltip

@onready var gui_thing_data_description: GUIThingDataDescription = %GUIThingDataDescription

func _update_with_data() -> void:
	var thing_data:ThingData = _data as ThingData
	gui_thing_data_description.update_with_thing_data(thing_data)
