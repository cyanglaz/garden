class_name GUIEnchantDescription
extends VBoxContainer

@onready var gui_enchant_icon: GUIEnchantIcon = %GUIEnchantIcon
@onready var title_label: Label = %TitleLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func update_with_enchant_data(enchant_data: EnchantData, combat_main: CombatMain) -> void:
	gui_enchant_icon.update_with_enchant_data(enchant_data, combat_main)
	title_label.text = enchant_data.get_display_name()
	var description := ActionDescriptionFormulator.get_action_description(enchant_data.action_data, combat_main)
	description = DescriptionParser.format_references(description, {}, {}, func(_id: String) -> bool: return false)
	if !description.ends_with("."):
		description += "."
	rich_text_label.text = description
