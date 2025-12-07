class_name RecycleBalls
extends Node2D

enum FlyingState {
	FRONT_1,
	FRONT_2,
	BACK_1,
	BACK_2,
}
const SIDE_FRONT_SCALE := 0.15
const CENTER_FRONT_SCALE := 0.20
const SIDE_BACK_SCALE := 0.15
const CENTER_BACK_SCALE := 0.10
const FLYING_DISTANCE_OFFSET := 10
const FLYING_TIME := 0.5

@onready var sprite: Sprite2D = %Sprite

var _distance :float = 10
var _target_scale:float
var _target_position:float
var _flying_state:FlyingState = FlyingState.FRONT_1
var _speed := 10.0
var _lap_time := 10.0
var _scale_speed := 0.0

func update_with_plant(plant:Plant) -> void:
	var sprite_frames:SpriteFrames = plant.plant_sprite.sprite_frames
	var current_animation:StringName = plant.plant_sprite.animation
	var frame_texture:Texture2D = sprite_frames.get_frame_texture(current_animation, 0)
	var image := frame_texture.get_image()
	var used_rect := image.get_used_rect()
	_distance = used_rect.size.x + FLYING_DISTANCE_OFFSET
	sprite.scale = Vector2(SIDE_FRONT_SCALE, SIDE_FRONT_SCALE)
	position.x = -_distance/2.0
	_lap_time = _distance/_speed

func _physics_process(delta: float) -> void:
	match _flying_state:
		FlyingState.FRONT_1:
			_target_scale = CENTER_FRONT_SCALE
			_scale_speed = (CENTER_FRONT_SCALE - SIDE_FRONT_SCALE)/_lap_time
			_target_position = 0
			sprite.z_index = 0
			_speed = abs(_speed)
		FlyingState.FRONT_2:
			_target_scale = SIDE_FRONT_SCALE
			_scale_speed = (SIDE_FRONT_SCALE - CENTER_FRONT_SCALE)/_lap_time
			_target_position = _distance/2
			sprite.z_index = 0
			_speed = abs(_speed)
		FlyingState.BACK_1:
			_target_scale = CENTER_BACK_SCALE
			_scale_speed = (CENTER_BACK_SCALE - SIDE_BACK_SCALE)/_lap_time
			_target_position = 0
			sprite.z_index = 0
			_speed = -abs(_speed)
		FlyingState.BACK_2:
			_target_scale = SIDE_BACK_SCALE
			_scale_speed = (SIDE_BACK_SCALE - CENTER_BACK_SCALE)/_lap_time
			_target_position = -_distance/2
			sprite.z_index = 0
			_speed = -abs(_speed)
	print(_scale_speed)
	sprite.scale.x += _scale_speed * delta
	sprite.scale.y = sprite.scale.x
	sprite.position.x += _speed * delta

	var next_state_index:int = (_flying_state + 1)%FlyingState.size()
	match _flying_state:
		FlyingState.FRONT_1, FlyingState.FRONT_2:
			if sprite.position.x >= _target_position:
				_flying_state = FlyingState.values()[next_state_index]
		FlyingState.BACK_1, FlyingState.BACK_2:
			if sprite.position.x <= _target_position:
				_flying_state = FlyingState.values()[next_state_index]
