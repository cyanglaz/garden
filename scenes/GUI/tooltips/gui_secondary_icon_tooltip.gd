class_name GUISecondaryIconTooltip
extends GUITooltip

@onready var _gui_status_icon_description: GUIStatusIconDescription = %GUIStatusIconDescription

func _update_with_tooltip_request() -> void:
	_gui_status_icon_description.update_with_status_data_array(_tooltip_request.data as Array)
