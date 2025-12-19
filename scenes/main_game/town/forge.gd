class_name Forge
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var smoke_particle: GPUParticles2D = %SmokeParticle
@onready var furnace_spark_particle: GPUParticles2D = %FurnaceSparkParticle
@onready var fire_particle: GPUParticles2D = %FireParticle
@onready var point_light_2d: PointLight2D = %PointLight2D

var highlighted := false: set = _set_highlighted

func _ready() -> void:
	smoke_particle.emitting = false
	furnace_spark_particle.emitting = false
	fire_particle.emitting = false
	point_light_2d.hide()

func _physics_process(_delta: float) -> void:
	if highlighted:
		point_light_2d.energy = randf_range(1.3, 1.7)

func _set_highlighted(val:bool) -> void:
	highlighted = val
	if highlighted:
		animated_sprite_2d.material.set_shader_parameter("outline_size", 1)
		animated_sprite_2d.play("open")
		smoke_particle.emitting = true
		furnace_spark_particle.emitting = true
		fire_particle.emitting = true
		point_light_2d.show()
	else:
		animated_sprite_2d.material.set_shader_parameter("outline_size", 0)
		animated_sprite_2d.play("closed")
		smoke_particle.emitting = false
		furnace_spark_particle.emitting = false
		fire_particle.emitting = false
		point_light_2d.hide()
