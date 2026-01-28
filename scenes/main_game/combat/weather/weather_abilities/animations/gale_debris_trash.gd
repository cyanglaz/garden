class_name GaleDebrisTrash
extends Node2D

const SCALE_RANGE := Vector2(0.8, 1.2)
const DROP_DURATION := 0.3

const DEBRIS_LEAF_IMAGE := preload("res://resources/sprites/effects/weather_ability/debris_leaf.png")
const DEBRIS_TWIG_IMAGE := preload("res://resources/sprites/effects/weather_ability/debris_twig.png")
const DEBRIS_PEBBLE_IMAGE := preload("res://resources/sprites/effects/weather_ability/debris_pebble.png")

const DEBRIS_IMAGES := [DEBRIS_LEAF_IMAGE, DEBRIS_TWIG_IMAGE, DEBRIS_PEBBLE_IMAGE]

@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var impact_audio: AudioStreamPlayer2D = %ImpactAudio

func _ready() -> void:
	rotation = randf_range(-PI, PI)
	scale = Vector2.ONE * randf_range(SCALE_RANGE.x, SCALE_RANGE.y)
	sprite_2d.texture = DEBRIS_IMAGES.pick_random()
	gpu_particles_2d.emitting = false
	gpu_particles_2d.one_shot = true

func fall(target_position:Vector2) -> void:
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(self, "global_position:y", target_position.y, DROP_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	impact_audio.play()
	sprite_2d.hide()
	gpu_particles_2d.restart()
