class_name GUIGenericDescription
extends VBoxContainer

const GUI_GENERAL_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_general_action.tscn")
const GUI_WEATHER_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_weather_action.tscn")

@onready var _action_container: VBoxContainer = %ActionContainer
@onready var _rich_text_label: RichTextLabel = %RichTextLabel

func update(actions:Array[ActionData], description:String) -> void:
	Util.remove_all_children(_action_container)
	for action_data:ActionData in actions:
		var action_scene:GUIAction = GUI_GENERAL_ACTION_SCENE.instantiate()
		_action_container.add_child(action_scene)
		action_scene.update_with_action(action_data)
	if !description.is_empty():
		_rich_text_label.text = description
