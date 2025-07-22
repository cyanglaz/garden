class_name GUIToolCardDescription
extends VBoxContainer

const ONE_ACTION_DESCRIPTION_SCENE := preload("res://scenes/GUI/shared/descriptions/shared_description/gui_one_action_description.tscn")

func update_with_tool_data(tool_data:ToolData) -> void:
	Util.remove_all_children(self)
	for action_data:ActionData in tool_data.actions:
		var action_description: GUIOneActionDescription = ONE_ACTION_DESCRIPTION_SCENE.instantiate()
		add_child(action_description)
		action_description.update_with_action_data(action_data)
	for special in tool_data.specials:
		var action_description: GUIOneActionDescription = ONE_ACTION_DESCRIPTION_SCENE.instantiate()
		add_child(action_description)
		action_description.update_with_tool_special(special)
