class_name GUIToolCardButton
extends GUIBasicButton

const GUI_TOOL_ACTION_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_action.tscn")

@onready var _name_label: Label = %NameLabel
@onready var _action_container: VBoxContainer = %ActionContainer
@onready var _gui_description_rich_text_label: GUIDescriptionRichTextLabel = %GUIDescriptionRichTextLabel
@onready var _container: PanelContainer = %Container
@onready var _background: NinePatchRect = %Background

func update_with_tool_data(tool_data:ToolData) -> void:
	_name_label.text = tool_data.display_name
	Util.remove_all_children(_action_container)
	for action_data:ActionData in tool_data.actions:
		var action_scene :GUIToolAction = GUI_TOOL_ACTION_SCENE.instantiate()
		_action_container.add_child(action_scene)
		action_scene.update_with_action(action_data)
	if !tool_data.get_display_description().is_empty():
		_gui_description_rich_text_label.text = tool_data.get_display_description()

func _set_button_state(bs:GUIBasicButton.ButtonState) -> void:
	super._set_button_state(bs)
	if bs == GUIBasicButton.ButtonState.HOVERED:
		_container.position.y = -1
		_background.region_rect.position.y = 16
	else:
		_container.position.y = 0
		_background.region_rect.position.y = 0
