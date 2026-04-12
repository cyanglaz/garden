class_name CardBindingEffect
extends Node2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var bind_core_burst: BindCoreBurst = %BindCoreBurst

func play_card_forging_effect(left_card:Control, right_card:Control, card_size:Vector2) -> void:
	var left_card_world_position = Util.get_control_global_position(self, left_card)
	var right_card_world_position = Util.get_control_global_position(self, right_card)
	var center_world_position = (left_card_world_position + right_card_world_position) / 2 + card_size / 2
	bind_core_burst.global_position = center_world_position
	await bind_core_burst.play_animation()
	audio_stream_player_2d.play()
