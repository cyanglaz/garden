class_name GUIOneActionDescription
extends VBoxContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var title_label: Label = %TitleLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func update_with_action_data(action_data:ActionData) -> void:
	var resource_id := Util.get_action_id_with_action_type(action_data.type)
	title_label.text = _get_action_name(action_data)
	rich_text_label.text = _get_action_description(action_data)
	texture_rect.texture = load(Util.get_image_path_for_resource_id(resource_id))

func _get_action_name(action_data:ActionData) -> String:
	var action_name := ""
	match action_data.type:
		ActionData.ActionType.LIGHT:
			action_name = tr("ACTION_NAME_LIGHT")
		ActionData.ActionType.WATER:
			action_name = tr("ACTION_NAME_WATER")
		ActionData.ActionType.PEST:
			action_name = tr("ACTION_NAME_PEST")
		ActionData.ActionType.FUNGUS:
			action_name = tr("ACTION_NAME_FUNGUS")
		ActionData.ActionType.GLOW:
			action_name = tr("ACTION_NAME_GLOW")
		ActionData.ActionType.WEATHER_SUNNY:
			action_name = tr("ACTION_NAME_WEATHER_SUNNY")
		ActionData.ActionType.WEATHER_RAINY:
			action_name = tr("ACTION_NAME_WEATHER_RAINY")
		ActionData.ActionType.DRAW_CARD:
			action_name = tr("ACTION_NAME_DRAW_CARD")
		ActionData.ActionType.NONE:
			pass
	return action_name

func _get_action_description(action_data:ActionData) -> String:
	var action_description := ""
	match action_data.type:
		ActionData.ActionType.LIGHT:
			action_description = tr("ACTION_DESCRIPTION_LIGHT")
		ActionData.ActionType.WATER:
			action_description = tr("ACTION_DESCRIPTION_WATER")
		ActionData.ActionType.PEST:
			action_description = tr("ACTION_DESCRIPTION_PEST")
		ActionData.ActionType.FUNGUS:
			action_description = tr("ACTION_DESCRIPTION_FUNGUS")
		ActionData.ActionType.GLOW:
			action_description = tr("ACTION_DESCRIPTION_GLOW")
		ActionData.ActionType.WEATHER_SUNNY:
			action_description = tr("ACTION_DESCRIPTION_WEATHER_SUNNY")
		ActionData.ActionType.WEATHER_RAINY:
			action_description = tr("ACTION_DESCRIPTION_WEATHER_RAINY")
		ActionData.ActionType.DRAW_CARD:
			action_description = tr("ACTION_DESCRIPTION_DRAW_CARD")
		ActionData.ActionType.NONE:
			pass
	if action_description.contains("%s"):
		action_description = action_description % abs(action_data.value)
	action_description = Util.formate_references(action_description, {}, {}, func(_reference_id:String) -> bool: return false)
	if action_description.begins_with(" "):
		action_description = action_description.substr(1)
	return action_description
