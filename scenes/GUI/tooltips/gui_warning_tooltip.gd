class_name GUIWarningTooltip
extends GUITooltip

@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func _update_with_tooltip_request() -> void:
	var text:String = _tooltip_request.data as String
	_rich_text_label.text = text
