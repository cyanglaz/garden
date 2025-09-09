class_name GUIEnemy
extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

func update_with_level_data(level_data:LevelData) -> void:
	if level_data.type == LevelData.Type.BOSS:
		show()
		texture_rect.texture = level_data.portrait_icon
	else:
		hide()

func play_flying_sound() -> void:
	audio_stream_player_2d.play()
