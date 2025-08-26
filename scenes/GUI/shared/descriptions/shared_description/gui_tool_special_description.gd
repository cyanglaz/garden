class_name GUIToolSpecialDescription
extends VBoxContainer

const ONE_ACTION_DESCRIPTION_SCENE := preload("res://scenes/GUI/shared/descriptions/shared_description/gui_one_action_description.tscn")

func update_with_specials(specials:Array) -> void:
	Util.remove_all_children(self)
	for special in specials:
		var action_description: GUIOneActionDescription = ONE_ACTION_DESCRIPTION_SCENE.instantiate()
		add_child(action_description)
		action_description.update_with_tool_special(special)
