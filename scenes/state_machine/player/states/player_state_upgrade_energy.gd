class_name PlayerStateUpgradeEnergy
extends PlayerState

@onready var upgrade_energy_audio: AudioStreamPlayer2D = %UpgradeEnergyAudio
@onready var energy_upgrade_particle: GPUParticles2D = %EnergyUpgradeParticle

func enter() -> void:
	super.enter()
	energy_upgrade_particle.restart()
	player.player_sprite.play_upgrade()
	upgrade_energy_audio.play()
	exit("")
