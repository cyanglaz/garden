class_name GUIStatusEffectTooltip
extends GUITooltip

@onready var _gui_status_effect_description: GUIStatusEffectDescription = %GUIStatusEffectDescription

func bind_status_effect_data(status_effect_data:StatusEffectData) -> void:
	_gui_status_effect_description.bind_status_effect_data(status_effect_data)
