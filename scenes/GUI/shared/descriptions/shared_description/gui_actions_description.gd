class_name GUIActionsDescription
extends VBoxContainer

const ONE_ACTION_DESCRIPTION_SCENE := preload("res://scenes/GUI/shared/descriptions/shared_description/gui_one_action_description.tscn")

func update_with_actions(action_datas:Array[ActionData]) -> void:
	Util.remove_all_children(self)
	for action_data:ActionData in action_datas:
		var action_description: GUIOneActionDescription = ONE_ACTION_DESCRIPTION_SCENE.instantiate()
		add_child(action_description)
		action_description.update_with_action_data(action_data)

func update_with_special(special:ToolData.Special) -> void:
	Util.remove_all_children(self)
	var action_description: GUIOneActionDescription = ONE_ACTION_DESCRIPTION_SCENE.instantiate()
	add_child(action_description)
	action_description.update_with_tool_special(special)