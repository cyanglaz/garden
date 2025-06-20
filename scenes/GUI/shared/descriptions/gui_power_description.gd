class_name GUIPowerDescription
extends VBoxContainer

@onready var _gui_power: GUIPower = %GUIPower
@onready var _name_label: Label = %NameLabel
@onready var _gui_power_cd_icon: GUIPowerCDIcon = %GUIPowerCDIcon
@onready var _gui_description_rich_text_label: GUIDescriptionRichTextLabel = %GUIDescriptionRichTextLabel

@export var tooltip_position:GUITooltip.TooltipPosition

func update_with_power_data(power_data:PowerData) -> void:
	_name_label.text = power_data.display_name
	_gui_description_rich_text_label.text = power_data.get_display_description(false)
	_gui_power_cd_icon.update_with_cd(power_data.cd)
	_gui_power.update_with_power_data(power_data)
	_gui_description_rich_text_label.tooltip_position = tooltip_position
