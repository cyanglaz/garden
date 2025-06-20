class_name GUIWarningTooltip
extends GUITooltip

@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func setup_with_text(val:String) -> void:
	_rich_text_label.text = val
