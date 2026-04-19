class_name CardEnchantingEffect
extends Node2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var enchant_core_burst: EnchantCoreBurst = %EnchantCoreBurst

func play_card_enchant_effect(burst_global_position:Vector2) -> void:
	enchant_core_burst.global_position = burst_global_position
	await enchant_core_burst.play_animation()
	audio_stream_player_2d.play()
