class_name GUIFieldSelectionArrow
extends Control

enum IndicatorState {
	HIDE,
	READY,
	CURRENT,
}

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var arrow: TextureRect = %Arrow

var indicator_state:IndicatorState = IndicatorState.HIDE: set = _set_indicator_state

func _set_indicator_state(value:IndicatorState) -> void:
	indicator_state = value
	match value:
		IndicatorState.HIDE:
			visible = false
		IndicatorState.READY:
			visible = true
			if !animation_player.is_playing():
				animation_player.play("active")
			(arrow.texture as AtlasTexture).region.position = Vector2(16, 0)
		IndicatorState.CURRENT:
			visible = true
			if !animation_player.is_playing():
				animation_player.play("active")
			(arrow.texture as AtlasTexture).region.position = Vector2(0, 0)
