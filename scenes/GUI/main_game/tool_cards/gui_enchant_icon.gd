class_name GUIEnchantIcon
extends PanelContainer

@onready var gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var label: Label = %Label

func update_with_enchant_data(enchant_data:EnchantData, combat_main:CombatMain) -> void:
	gui_action_type_icon.update_with_action_type(enchant_data.action_data.type)
	label.text = str(enchant_data.action_data.get_calculated_value(combat_main))
