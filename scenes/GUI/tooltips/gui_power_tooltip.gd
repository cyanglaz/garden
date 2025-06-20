class_name GUIPowerTooltip
extends GUITooltip

@onready var _gui_power_description: GUIPowerDescription = %GUIPowerDescription

func bind_with_power_data(power_data:PowerData) -> void:
	_gui_power_description.update_with_power_data(power_data)

func _set_tooltip_position(val:GUITooltip.TooltipPosition) -> void:
	super._set_tooltip_position(val)
	_gui_power_description.tooltip_position = val
