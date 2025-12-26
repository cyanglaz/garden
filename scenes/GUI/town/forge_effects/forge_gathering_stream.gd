class_name ForgeGatheringStream
extends Node2D

@onready var left_stream: GPUParticles2D = %LeftStream
@onready var right_stream: GPUParticles2D = %RightStream
@onready var left_card: GPUParticles2D = %LeftCard
@onready var right_card: GPUParticles2D = %RightCard

func play_forge_gathering_stream(left_card_position:Vector2, right_card_position:Vector2, card_size:Vector2, center_world_position:Vector2) -> void:
	show()

	left_stream.emitting = false
	right_stream.emitting = false
	left_card.emitting = false
	right_card.emitting = false
	(left_stream.process_material as ParticleProcessMaterial).emission_box_extents = Vector3(card_size.x/2, card_size.y/2, 1)
	left_card.process_material.emission_box_extents = (left_stream.process_material as ParticleProcessMaterial).emission_box_extents
	(right_stream.process_material as ParticleProcessMaterial).emission_box_extents = Vector3(card_size.x/2, card_size.y/2, 1)
	right_card.process_material.emission_box_extents = (right_stream.process_material as ParticleProcessMaterial).emission_box_extents
	left_stream.global_position = left_card_position + card_size / 2
	right_stream.global_position = right_card_position + card_size / 2
	left_stream.look_at(center_world_position)
	right_stream.look_at(center_world_position)
	left_card.position = left_stream.global_position
	right_card.position = right_stream.global_position
	

	var distance = left_card_position.distance_to(center_world_position)
	var speed = left_stream.process_material.initial_velocity_max
	var required_lifetime = distance / speed

	left_stream.lifetime = required_lifetime
	right_stream.lifetime = required_lifetime
	left_card.lifetime = required_lifetime
	right_card.lifetime = required_lifetime
	left_stream.one_shot = true
	right_stream.one_shot = true
	left_card.one_shot = true
	right_card.one_shot = true

	left_card.emitting = true
	right_card.emitting = true

	var tween = Util.create_scaled_tween(self)
	tween.tween_property(left_card, "amount", 0.0, required_lifetime).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(right_card, "amount", 0.0, required_lifetime).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	
	left_stream.emitting = true
	right_stream.emitting = true

	await Util.create_scaled_timer(required_lifetime).timeout
	
