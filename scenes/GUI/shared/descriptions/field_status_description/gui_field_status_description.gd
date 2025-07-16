class_name GUIFieldStatusDescription
extends VBoxContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var title_label: Label = %TitleLabel
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func update_with_status_data(field_status_data:FieldStatusData) -> void:
	texture_rect.texture = load(Util.get_image_path_for_resource_id(field_status_data.id))
	title_label.text = field_status_data.display_name
	rich_text_label.text = field_status_data.get_display_description()
