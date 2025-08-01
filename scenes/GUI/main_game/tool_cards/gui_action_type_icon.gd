class_name GUIActionTypeIcon
extends TextureRect

func update_with_action_type(action_type:ActionData.ActionType) -> void:
	var id:String = Util.get_action_id_with_action_type(action_type)
	#assert(!id.is_empty(), "id is empty")
	texture = load(Util.get_image_path_for_resource_id(id))
