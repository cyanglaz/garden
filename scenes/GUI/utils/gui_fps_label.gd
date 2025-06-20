extends Label

func _ready() -> void:
	PlayerSettings.fps_displayed.connect(_on_fps_displayed)
	visible = PlayerSettings.get_setting_data().display_fps
		
func _process(_delta: float) -> void:
	if !visible:
		return
	text = "FPS: %s" % [Engine.get_frames_per_second()]
 
func _on_fps_displayed(enabled:bool) -> void:
	visible = enabled
