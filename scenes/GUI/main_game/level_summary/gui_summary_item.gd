class_name GUISummaryItem
extends HBoxContainer

@export var title_localized_string:String

@onready var title_label: Label = %TitleLabel
@onready var value_label: Label = %ValueLabel

var value_text:String : set = _set_value_text

func _ready() -> void:
	title_label.text = Util.get_localized_string(title_localized_string)

func _set_value_text(val:String) -> void:
	value_text = val
	value_label.text = val
