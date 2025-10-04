class_name GUIOneActionDescription
extends VBoxContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var title_label: Label = %TitleLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func update_with_tool_special(special:ToolData.Special) -> void:
	var resource_id := Util.get_id_for_tool_speical(special)
	texture_rect.texture = load(Util.get_image_path_for_resource_id(resource_id))
	title_label.text = ActionDescriptionFormulator.get_special_name(special)
	rich_text_label.text = ActionDescriptionFormulator.get_special_description(special)

func update_with_action_data(action_data:ActionData) -> void:
	var resource_id := Util.get_action_id_with_action_type(action_data.type)
	texture_rect.texture = load(Util.get_image_path_for_resource_id(resource_id))
	title_label.text = _get_action_name(action_data)
	rich_text_label.text = _get_action_description(action_data)

func _get_action_name(action_data:ActionData) -> String:
	var action_name := Util.get_action_name_from_action_type(action_data.type)
	return action_name

func _get_action_description(action_data:ActionData) -> String:
	var action_description := ActionDescriptionFormulator.get_action_description(action_data)
	action_description = DescriptionParser.format_references(action_description, {}, {}, func(_reference_id:String) -> bool: return false)
	if !action_description.ends_with("."):
		action_description += "."
	return action_description
