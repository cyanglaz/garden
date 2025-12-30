class_name ForgeCoreBurst
extends Node2D

const WAIT_TIME := 0.1

@onready var explode: GPUParticles2D = %Explode
@onready var petals: GPUParticles2D = %Petals

func play_animation() -> void:
	explode.restart()
	explode.emitting = true
	await Util.create_scaled_timer(WAIT_TIME).timeout
