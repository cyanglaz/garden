class_name GUIToolCardButton
extends GUIBasicButton

const GUI_TOOL_ACTION_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_action.tscn")

@onready var _name_label: Label = %NameLabel
@onready var _action_container: VBoxContainer = %ActionContainer
@onready var _gui_description_rich_text_label: GUIDescriptionRichTextLabel = %GUIDescriptionRichTextLabel



func update_with_tool_data(tool_data:ToolData) -> void:
	_name_label.text = tool_data.display_name
	Util.remove_all_children(_action_container)
	for action_data:ActionData in tool_data.actions:
		var action_scene :GUIToolAction = GUI_TOOL_ACTION_SCENE.instantiate()
		_action_container.add_child(action_scene)
		action_scene.update_with_action(action_data)
	if !tool_data.get_display_description().is_empty():
		_gui_description_rich_text_label.text = tool_data.get_display_description()
