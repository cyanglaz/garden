class_name GUIWarningTooltip
extends GUITooltip

@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func _update_with_data() -> void:
	var text:String = _data as String
	_rich_text_label.text = text