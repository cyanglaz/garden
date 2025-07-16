class_name GUIFieldStatusTooltip
extends GUITooltip

@onready var _gui_field_status_description: GUIFieldStatusDescription = %GUIFieldStatusDescription

func update_with_field_status_data(field_status_data:FieldStatusData) -> void:
	_gui_field_status_description.update_with_status_data(field_status_data)
