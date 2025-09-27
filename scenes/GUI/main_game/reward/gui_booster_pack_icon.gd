class_name GUIBoosterPackIcon
extends TextureRect

const COMMON_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_common.png")
const RARE_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_rare.png")
const LEGENDARY_TEXTURE := preload("res://resources/sprites/booster_packs/booster_pack_legendary.png")

var has_outline:bool = true: set = _set_has_outline

func update_with_booster_pack_type(booster_pack_type:ContractData.BoosterPackType) -> void:
	match booster_pack_type:
		ContractData.BoosterPackType.COMMON:
			texture = COMMON_TEXTURE
		ContractData.BoosterPackType.RARE:
			texture = RARE_TEXTURE
		ContractData.BoosterPackType.LEGENDARY:
			texture = LEGENDARY_TEXTURE

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if val:
		material.set_shader_parameter("outline_size", 1)
	else:
		material.set_shader_parameter("outline_size", 0)
