class_name PlantAttack
extends Node2D

const SHAKE_OFFSET := Vector2(-2, -2)
const Y_OFFSET := 6.0

@onready var control: Control = $Control
@onready var label: Label = %Label
@onready var texture_rect: TextureRect = %TextureRect

var damage := 0

func attack() -> void:
	var original_position := texture_rect.position
	var tween:= Util.create_scaled_tween(self)
	tween.tween_property(texture_rect, "position", original_position + SHAKE_OFFSET, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(texture_rect, "position", original_position - SHAKE_OFFSET/2.0, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(texture_rect, "position", original_position, 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	Events.request_hp_update.emit(-damage)

func update_with_plant(plant:Plant) -> void:
	match plant.data.difficulty:
		0:
			damage = 3
		1:
			damage = 5
		2:
			damage = 7
		_:
			assert(false, "Invalid difficulty: " + str(plant.data.difficulty))
	label.text = str(damage)
	var used_rect := plant.plant_sprite.sprite_frames.get_frame_texture(plant.plant_sprite.animation, 0).get_image().get_used_rect()
	position.y = - used_rect.size.y - Y_OFFSET
