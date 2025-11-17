class_name GUIBoosterPackImage
extends PanelContainer

const COMMON_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_common.png")
const RARE_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_rare.png")
const LEGENDARY_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_legendary.png")

const OPEN_ANIMATION_SIGNAL_TIME := 0.6

@onready var shake: Shake = %Shake
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var texture_rect: TextureRect = %TextureRect

var has_outline:bool = true: set = _set_has_outline

func play_open_animation() -> void:
	animation_player.play("open")
	await Util.create_scaled_timer(OPEN_ANIMATION_SIGNAL_TIME).timeout

func update_with_booster_pack_type(booster_pack_type:ContractData.BoosterPackType) -> void:
	match booster_pack_type:
		ContractData.BoosterPackType.COMMON:
			texture_rect.texture = COMMON_TEXTURE
		ContractData.BoosterPackType.RARE:
			texture_rect.texture = RARE_TEXTURE
		ContractData.BoosterPackType.LEGENDARY:
			texture_rect.texture = LEGENDARY_TEXTURE
		
func _start_shaking() -> void:
	shake.start(1.0,Vector2(1, 1), 0.01, 0.0, 1)

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if val:
		texture_rect.material.set_shader_parameter("outline_size", 1)
	else:
		texture_rect.material.set_shader_parameter("outline_size", 0)
