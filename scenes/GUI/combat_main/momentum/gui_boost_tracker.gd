class_name GUIBoostTracker
extends HBoxContainer

@onready var title_label: Label = %TitleLabel
@onready var value_label: Label = %ValueLabel

func _ready() -> void:
	title_label.text = Util.get_localized_string("BOOST_TRACKER_TITLE")

func update_boost(boost:int) -> void:
	value_label.text = str(boost)
