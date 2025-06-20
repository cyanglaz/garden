class_name GUIRichTextTooltip
extends GUITooltip

@onready var _description: RichTextLabel = %Description

func setup(description:String) -> void:
	_description.text = description
	var line_count := _description.get_line_count()
	if line_count > 1:
		_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
