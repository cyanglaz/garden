class_name ForgeCoreBurst
extends Node2D

@onready var explode: GPUParticles2D = %Explode
@onready var petals: GPUParticles2D = %Petals

func play_animation() -> void:
	explode.restart()
	explode.emitting = true
	await explode.finished
