class_name FieldStatusDew
extends FieldStatus

@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D

func _ready() -> void:
	gpu_particles_2d.emitting = false

func _update_for_plant(plant:Plant) -> void:
	super._update_for_plant(plant)
	_resize_gpu_particles_2d()
	gpu_particles_2d.emitting = true

func _has_tool_discard_hook(_count:int, plant:Plant) -> bool:
	return plant != null

func _handle_tool_discard_hook(plant:Plant, count:int) -> void:
	var action:ActionData = ActionData.new()
	var water_gain := (status_data.data["water"] as int) * stack * count
	action.type = ActionData.ActionType.WATER
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = water_gain
	await plant.apply_actions([action])

func _resize_gpu_particles_2d() -> void:
	var plant:Plant = get_parent().get_parent()
	var used_rect := plant.plant_sprite.sprite_frames.get_frame_texture(plant.plant_sprite.animation, 0).get_image().get_used_rect()
	gpu_particles_2d.process_material.emission_box_extents = Vector3(used_rect.size.x/2.0, used_rect.size.y/2.0, 1)
	gpu_particles_2d.amount = stack
	gpu_particles_2d.position.y = - used_rect.size.y/2.0
