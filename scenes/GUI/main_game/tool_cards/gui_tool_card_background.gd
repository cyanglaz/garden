class_name GUIToolCardBackground
extends NinePatchRect

const IMAGE_WIDTH:int = 40

func update_with_rarity(rarity:int) -> void:
	match rarity:
		-1:
			region_rect.position.x = 0
		0:
			region_rect.position.x = IMAGE_WIDTH
		1:
			region_rect.position.x = IMAGE_WIDTH * 2
		2:
			region_rect.position.x = IMAGE_WIDTH * 3
		
func toggle_outline(has_outline:bool, color:Color) -> void:
	if has_outline:
		material.set_shader_parameter("outline_size", 1)
		material.set_shader_parameter("outline_color", color)
	else:
		material.set_shader_parameter("outline_size", 0)
