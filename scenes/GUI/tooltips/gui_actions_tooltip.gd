class_name GUIActionsTooltip
extends GUITooltip

@onready var _gui_actions_description: GUIActionsDescription = %GUIActionsDescription

func _update_with_data() -> void:
	_gui_actions_description.update_with_actions(_data as Array, null)

func get_action_description(index:int) -> String:
	var one_action_description:GUIOneActionDescription = _gui_actions_description.get_child(index)
	return one_action_description.rich_text_label.text
