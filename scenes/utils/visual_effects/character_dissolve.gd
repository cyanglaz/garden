class_name CharacterDeathDissolve
extends Node2D

signal finished()

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _sprite_2d: Sprite2D = %Sprite2D

func play_dissolve(character:Character) -> void:
	character.character_sprite_group.sprite_animation_player.pause()
	character.character_sprite_group.character_sprite.hide()
	var current_image := Util.get_current_image_from_sprite(character.character_sprite_group.character_sprite)
	var bigger_image := Image.create(current_image.get_size().x * 5, current_image.get_size().y * 5, true, current_image.get_format())
	@warning_ignore("integer_division")
	var blend_dst := Vector2i((bigger_image.get_size().x - current_image.get_size().x)/2, (bigger_image.get_size().y - current_image.get_size().y)/2)
	bigger_image.blend_rect(current_image, Rect2i(0, 0, current_image.get_size().x, current_image.get_size().y), blend_dst)
	_sprite_2d.texture = ImageTexture.create_from_image(bigger_image)
	_animation_player.play("dissolve")
	await _animation_player.animation_finished
	finished.emit()
	queue_free()
