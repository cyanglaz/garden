class_name GUISpecialsTooltip
extends GUITooltip

@onready var gui_tool_special_description: GUIToolSpecialDescription = %GUIToolSpecialDescription

func _update_with_tooltip_request() -> void:
	gui_tool_special_description.update_with_specials(_tooltip_request.data as Array)

func get_special_description(index:int) -> String:
	var one_special_description:GUIOneActionDescription = gui_tool_special_description.get_child(index)
	return one_special_description.rich_text_label.text
