class_name GUIActionTypeIcon
extends TextureRect

func update_with_action_type(action_type:ActionData.ActionType) -> void:
	texture = Util.get_action_icon_with_action_type(action_type)
