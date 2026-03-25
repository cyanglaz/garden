class_name GUIStatusIconDescription
extends VBoxContainer

const ONE_ACTION_DESCRIPTION_SCENE := preload("res://scenes/GUI/shared/descriptions/shared_description/gui_one_action_description.tscn")

func update_with_status_data_array(status_data_array: Array) -> void:
	Util.remove_all_children(self)
	for status_data: ThingData in status_data_array:
		var item: GUIOneActionDescription = ONE_ACTION_DESCRIPTION_SCENE.instantiate()
		add_child(item)
		item.update_with_status_data(status_data)
