class_name GUIActionList
extends VBoxContainer

const GUI_GENERAL_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_general_action.tscn")

@onready var _action_container: VBoxContainer = %ActionContainer

func update(actions:Array[ActionData]) -> void:
	Util.remove_all_children(_action_container)
	for action_data:ActionData in actions:
		if action_data.value_type == ActionData.ValueType.X:
			var action_scene_x:GUIGeneralAction = GUI_GENERAL_ACTION_SCENE.instantiate()
			_action_container.add_child(action_scene_x)
			action_scene_x.update_for_x(action_data.x_value, action_data.x_value_type)
		var action_scene:GUIGeneralAction = GUI_GENERAL_ACTION_SCENE.instantiate()
		_action_container.add_child(action_scene)
		action_scene.update_with_action(action_data)
