class_name GUITownBuildingTooltip
extends GUITooltip

@onready var name_label: Label = %NameLabel
@onready var description: RichTextLabel = %Description

func _update_with_tooltip_request() -> void:
	var name_text:String = _tooltip_request.additional_data["name"]
	var description_text:String = _tooltip_request.additional_data["description"]
	name_label.text = name_text
	description.text = description_text
