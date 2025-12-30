class_name CardForgingEffect
extends Node2D

@onready var forge_gathering_stream: ForgeGatheringStream = %ForgeGatheringStream
@onready var forge_core_burst: ForgeCoreBurst = %ForgeCoreBurst
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

func play_card_forging_effect(left_card:Control, right_card:Control, card_size:Vector2) -> void:
	var left_card_world_position = Util.get_control_global_position(self, left_card)
	var right_card_world_position = Util.get_control_global_position(self, right_card)
	var center_world_position = (left_card_world_position + right_card_world_position) / 2 + card_size / 2
	#await forge_gathering_stream.play_forge_gathering_stream(left_card_world_position, right_card_world_position, card_size, center_world_position)
	#print("center_world_position: ", center_world_position)
	forge_core_burst.global_position = center_world_position
	await forge_core_burst.play_animation()
	audio_stream_player_2d.play()
