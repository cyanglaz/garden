class_name FieldStatusPest
extends FieldStatus

const PEST_AREA_HORIZONTAL_OFFSET := 10.0

const PEST_SCENE := preload("res://scenes/main_game/field/status/status_components/pest.tscn")

@onready var pests_container: Node2D = %PestsContainer

func _update_for_plant(plant:Plant) -> void:
	_respawn_pests(plant)

func _has_end_turn_hook(_plant:Plant) -> bool:
	return true

func _handle_end_turn_hook(_combat_main:CombatMain, _plant:Plant) -> void:
	Events.request_hp_update.emit(-(status_data.data["value"] as int) * stack)

func _respawn_pests(plant:Plant) -> void:
	Util.remove_all_children(pests_container)
	print(stack)
	var sprite_frames:SpriteFrames = plant.plant_sprite.sprite_frames
	var current_animation:StringName = plant.plant_sprite.animation
	var frame_texture:Texture2D = sprite_frames.get_frame_texture(current_animation, 0)
	var image := frame_texture.get_image()
	var used_rect := image.get_used_rect()
	pests_container.position = Vector2(0, - used_rect.size.y/2.0)
	for i in stack:
		var pest:Pest = PEST_SCENE.instantiate()
		pest.moving_area_size = Vector2(used_rect.size.x + 10, used_rect.size.y)
		pests_container.add_child(pest)
		print(pest.moving_area_size)
