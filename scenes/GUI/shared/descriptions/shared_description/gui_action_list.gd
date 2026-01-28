class_name GUIActionList
extends VBoxContainer

const GUI_GENERAL_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_general_action.tscn")

@export var action_alignment:GUIGeneralAction.ActionAlignment = GUIGeneralAction.ActionAlignment.CENTER
@onready var _action_container: VBoxContainer = %ActionContainer

func update(actions:Array[ActionData], target_plant:Plant) -> void:
	Util.remove_all_children(_action_container)
	for action_data:ActionData in actions:
		if action_data.value_type == ActionData.ValueType.X:
			var action_scene_x:GUIGeneralAction = GUI_GENERAL_ACTION_SCENE.instantiate()
			_action_container.add_child(action_scene_x)
			action_scene_x.update_for_x(action_data.get_calculated_x_value(target_plant), action_data.x_value_type)
			action_scene_x.action_alignment = action_alignment
		var action_scene:GUIGeneralAction = GUI_GENERAL_ACTION_SCENE.instantiate()
		action_scene.action_alignment = action_alignment
		_action_container.add_child(action_scene)
		action_scene.update_with_action(action_data, target_plant)
