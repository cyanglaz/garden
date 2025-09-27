class_name GUIBoosterPackButton
extends GUIBasicButton

const COMMON_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_common.png")
const RARE_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_rare.png")
const LEGENDARY_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_legendary.png")

@onready var texture_rect: TextureRect = %TextureRect

var has_outline:bool = true: set = _set_has_outline

func update_with_booster_pack_type(booster_pack_type:ContractData.BoosterPackType) -> void:
	match booster_pack_type:
		ContractData.BoosterPackType.COMMON:
			texture_rect.texture = COMMON_TEXTURE
		ContractData.BoosterPackType.RARE:
			texture_rect.texture = RARE_TEXTURE
		ContractData.BoosterPackType.LEGENDARY:
			texture_rect.texture = LEGENDARY_TEXTURE

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	_set_has_outline(true)

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	_set_has_outline(false)

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if val:
		texture_rect.material.set_shader_parameter("outline_size", 1)
	else:
		texture_rect.material.set_shader_parameter("outline_size", 0)
