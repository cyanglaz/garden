class_name GUIGenericDescription
extends VBoxContainer

const GUI_FIELD_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_field_action.tscn")
const GUI_WEATHER_ACTION_SCENE := preload("res://scenes/GUI/main_game/actions/gui_weather_action.tscn")

@onready var _name_label: Label = %NameLabel
@onready var _action_container: VBoxContainer = %ActionContainer
@onready var _gui_description_rich_text_label: GUIDescriptionRichTextLabel = %GUIDescriptionRichTextLabel

func update(display_name:String, actions:Array[ActionData], description:String) -> void:
	_name_label.text = display_name
	Util.remove_all_children(_action_container)
	for action_data:ActionData in actions:
		var action_scene:GUIAction
		match action_data.action_category:
			ActionData.ActionCategory.FIELD:
				action_scene = GUI_FIELD_ACTION_SCENE.instantiate()
			ActionData.ActionCategory.WEATHER:
				action_scene = GUI_WEATHER_ACTION_SCENE.instantiate()
			_:
				assert(false, "Invalid action category: " + str(action_data.action_category))
		_action_container.add_child(action_scene)
		action_scene.update_with_action(action_data)
	if !description.is_empty():
		_gui_description_rich_text_label.text = description
