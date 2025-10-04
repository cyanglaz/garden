class_name GUIActionsTooltip
extends GUITooltip

@onready var _gui_actions_description: GUIActionsDescription = %GUIActionsDescription

func update_with_special(special:ToolData.Special) -> void:
	_gui_actions_description.update_with_special(special)

func update_with_actions(actions:Array[ActionData]) -> void:
	_gui_actions_description.update_with_actions(actions)
	
func get_action_description(index:int) -> String:
	var one_action_description:GUIOneActionDescription = _gui_actions_description.get_child(index)
	return one_action_description.rich_text_label.text