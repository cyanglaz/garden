class_name GUITaxDue
extends HBoxContainer

@onready var _label: Label = %Label
@onready var _gui_gold: GUIGold = $GUIGold

func _ready() -> void:
	_label.text = tr("TAX_DUE_TITLE")

func update_tax_due(gold:int) -> void:
	_gui_gold.update_gold(gold, GUIGold.AnimationType.FULL)
