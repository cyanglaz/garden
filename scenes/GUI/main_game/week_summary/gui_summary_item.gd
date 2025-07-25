class_name GUISummaryItem
extends HBoxContainer

@onready var title_label: Label = %TitleLabel
@onready var gold_label: Label = %GoldLabel

func update_with_title_and_gold(title:String, gold:int, gold_tax_color:Color) -> void:
	title_label.text = title
	gold_label.text = str(gold)
	gold_label.add_theme_color_override("font_color", gold_tax_color)
