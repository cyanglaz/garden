class_name WeatherSpriteContainer
extends Node2D

signal animated_in_finished()
signal animated_out_finished()

const SPRITE_DELAY_MIN := 0.05
const SPRITE_DELAY_MAX := 0.1

var _sprites:Array[WeatherSprite]
var _sprites_animation_count := 0

func _ready() -> void:
	for child in get_children():
		assert(child is WeatherSprite, "Child is not a WeatherSprite")
		child.animated_in_finished.connect(_on_sprite_animated_in_finished)
		child.animated_out_finished.connect(_on_sprite_animated_out_finished)
		_sprites.append(child)
		print("orignial position: ", child.global_position)

func animate_sprites_in() -> void:
	if _sprites.is_empty():
		return
	_sprites_animation_count = _sprites.size()
	for sprite in _sprites:
		Util.create_scaled_timer(randf_range(SPRITE_DELAY_MIN, SPRITE_DELAY_MAX)).timeout.connect(func(): sprite.animate_in())
	await animated_in_finished

func animate_sprites_out() -> void:
	if _sprites.is_empty():
		return
	_sprites_animation_count = _sprites.size()
	for sprite in _sprites:
		Util.create_scaled_timer(randf_range(SPRITE_DELAY_MIN, SPRITE_DELAY_MAX)).timeout.connect(func(): sprite.animate_out())
	await animated_out_finished

func _on_sprite_animated_in_finished() -> void:
	_sprites_animation_count -= 1
	if _sprites_animation_count == 0:
		animated_in_finished.emit()
		for sprite in _sprites:
			print("sprite position: ", sprite.global_position)

func _on_sprite_animated_out_finished() -> void:
	_sprites_animation_count -= 1
	if _sprites_animation_count == 0:
		animated_out_finished.emit()
