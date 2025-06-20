class_name GUICharacterIcon
extends TextureRect

const ICON_PREFIX := "res://resources/sprites/icons/characters/icon_"
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func bind_character(character_data:CharacterData) -> void:
	var path := str(ICON_PREFIX, character_data.id, ".png")
	texture = load(path)

func animate_being_attacked() -> void:
	animation_player.play("flash")

func add_outline(color:Color) -> void:
	material.set_shader_parameter("has_outline", true)
	material.set_shader_parameter("outline_color", color)

func remove_outline() -> void:
	material.set_shader_parameter("has_outline", false)
