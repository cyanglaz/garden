class_name GUIEnemy
extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect

func update_with_level_data(level_data:LevelData) -> void:
	if level_data.type == LevelData.Type.BOSS:
		show()
		texture_rect.texture = level_data.portrait_icon
	else:
		hide()
