class_name GUISettingsButton
extends GUIBasicButton

@onready var _texture_rect: NinePatchRect = %TextureRect

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_texture_rect:
		return
	match button_state:
		ButtonState.NORMAL:
			_texture_rect.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			_texture_rect.region_rect.position = Vector2(10, 0)
		ButtonState.HOVERED:
			_texture_rect.region_rect.position = Vector2(20, 0)
		ButtonState.DISABLED:
			_texture_rect.region_rect.position = Vector2(0, 10)
		ButtonState.SELECTED:
			_texture_rect.region_rect.position = Vector2(20, 10)		

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("pause"):
		#if get_tree().paused:
			#return
		#_on_action_evoked()
