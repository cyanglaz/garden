class_name GUISpaceEffectTooltip
extends GUITooltip

@onready var _gui_space_effect_description: GUISpaceEffectDescription = %GUISpaceEffectDescription

func bind_space_effect(space_effect:SpaceEffect) -> void:
	_gui_space_effect_description.bind_space_effect(space_effect)
