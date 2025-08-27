class_name GUICharacter
extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect

func update_with_player_data(player_data:PlayerData) -> void:
	texture_rect.texture = player_data.portrait_icon
