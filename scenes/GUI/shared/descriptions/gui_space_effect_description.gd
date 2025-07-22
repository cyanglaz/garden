class_name GUISpaceEffectDescription
extends VBoxContainer

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _name_label: Label = %NameLabel
@onready var _rich_text_label: RichTextLabel = %RichTextLabel
@onready var _type_label: Label = %TypeLabel

func bind_space_effect(space_effect:SpaceEffect) -> void:
	_texture_rect.texture = load(Util.get_image_path_for_space_effect_id(space_effect.data.id))
	_name_label.text = space_effect.data.display_name
	_rich_text_label.text = space_effect.get_formatted_description()
	_type_label.text = Util.get_localized_string("GLYPH")
