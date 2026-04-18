class_name GUIEnchantTooltip
extends GUITooltip

@onready var gui_enchant_description: GUIEnchantDescription = %GUIEnchantDescription

func _update_with_tooltip_request() -> void:
	gui_enchant_description.update_with_enchant_data(
		_tooltip_request.data as EnchantData,
		_tooltip_request.combat_main
	)
