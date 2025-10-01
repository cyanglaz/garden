class_name GUIBoosterPackButton
extends GUIBasicButton

@onready var gui_booster_pack_image: GUIBoosterPackImage = $GUIBoosterPackImage

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	gui_booster_pack_image.has_outline = true

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	gui_booster_pack_image.has_outline = false

func update_with_booster_pack_type(booster_pack_type:ContractData.BoosterPackType) -> void:
	gui_booster_pack_image.update_with_booster_pack_type(booster_pack_type)
