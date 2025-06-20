class_name GUIBasicSlider
extends HSlider

const SOUND_CLICK := preload("res://resources/sounds/GUI/button_click.wav")
const SOUND_TICK := preload("res://resources/sounds/GUI/slider_tick.wav")

@onready var _sound_tick := AudioStreamPlayer2D.new()

func _ready() -> void:
	_sound_tick.stream = SOUND_TICK
	_sound_tick.volume_db = -5
	_sound_tick.bus = "SFX"
	add_child(_sound_tick, false, Node.INTERNAL_MODE_BACK)
	value_changed.connect(_on_value_changed)

func _on_value_changed(_val:float) -> void:
	_sound_tick.play()
