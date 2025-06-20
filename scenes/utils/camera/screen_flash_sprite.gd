class_name ScreenFlashSprite
extends TextureRect

func _ready() -> void:
	Events.request_camera_flash_effects.connect(_on_request_camera_flash_effects)

func feedback_flash_screen(time:float, color:Color = Color.WHITE, number_of_flashes:int = 1, flash_interval:float = 0):	
	_flash_sprite(time, color, number_of_flashes, flash_interval)
	
func _flash_sprite(time:float, color:Color = Color.WHITE, number_of_flashes:int = 1, flash_interval:float = 0):
	for i in number_of_flashes:	
		if i > 0:
			await Util.create_scaled_timer(flash_interval).timeout
		var tween_flash = Util.create_scaled_tween(self)
		tween_flash.tween_property(self, "modulate", color, time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween_flash.tween_property(self, "modulate", Color.TRANSPARENT, time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween_flash.play()

	
func _on_request_camera_flash_effects(flash_length:float, color:Color, number_of_flashes:int, flash_interval:float):
	feedback_flash_screen(flash_length, color, number_of_flashes, flash_interval)
