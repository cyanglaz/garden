class_name GUIStatusEffectDescription
extends VBoxContainer

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _name_label: Label = %NameLabel
@onready var _rich_text_label: RichTextLabel = %RichTextLabel
@onready var _type_label: Label = %TypeLabel

func bind_status_effect_data(status_effect_data:StatusEffectData) -> void:
	_texture_rect.texture = load(Util.get_image_path_for_status_effect_id(status_effect_data.id))
	_name_label.text = status_effect_data.display_name
	_rich_text_label.text = status_effect_data.get_formatted_description()
	_type_label.text = tr("SIGIL")
	_type_label.self_modulate = Constants.COLOR_WHITE
