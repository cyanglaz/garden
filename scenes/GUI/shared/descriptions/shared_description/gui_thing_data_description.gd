class_name GUIThingDataDescription
extends VBoxContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var title_label: Label = %TitleLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func update_with_thing_data(thing_data:ThingData) -> void:
	var image := Util.get_image_path_for_resource_id(thing_data.id)
	if image:
		texture_rect.texture = load(Util.get_image_path_for_resource_id(thing_data.id))
	else:
		texture_rect.hide()
	title_label.text = thing_data.display_name
	rich_text_label.text = thing_data.get_display_description()
