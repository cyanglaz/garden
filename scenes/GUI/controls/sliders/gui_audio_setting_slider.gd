@tool

class_name GUIAudioSettingSlider
extends HBoxContainer

signal value_changed(value: float)

@export var audio_bus:String: set = _set_audio_bus

@onready var _label := %Title
@onready var _slider := %GUIBasicSlider

func _ready() -> void:
	_slider.value_changed.connect(_on_value_changed)
	_slider.min_value = Constants.MINIMUM_AUDIO
	_slider.max_value = Constants.MAXIMUM_AUDIO
	_slider.step = (_slider.max_value - _slider.min_value)/10
	_set_audio_bus(audio_bus)

func reset_slider_value() -> void:
	_slider.set_value_no_signal(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(audio_bus)))

func _setup_label() -> void:
	_label.text = audio_bus.capitalize()

func _on_value_changed(value: float) -> void:
	value_changed.emit(value)

func _set_audio_bus(val:String) -> void:
	audio_bus = val
	if _label:
		_label.text = audio_bus.capitalize()
		_slider.set_value_no_signal(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(audio_bus)))
