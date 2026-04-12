class_name GUIActionsTooltip
extends GUITooltip

@onready var _gui_actions_description: GUIActionsDescription = %GUIActionsDescription

func _update_with_tooltip_request() -> void:
	_gui_actions_description.update_with_actions(_tooltip_request.data as Array, _tooltip_request.combat_main)

func get_action_description(index:int) -> String:
	var one_action_description:GUIOneActionDescription = _gui_actions_description.get_child(index)
	return one_action_description.rich_text_label.text
