class_name GUIEnergyBar
extends PanelContainer

signal energy_update_animation_finished()
signal energy_full_animation_finished()

const ENERGY_UPDATE_ANIMATION_DURATION:float = 0.05

@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var _guirp_bar: GUIRPBar = %GUIRPBar

func _ready() -> void:
	_guirp_bar.value_update_finished.connect(func():
		energy_update_animation_finished.emit()
	)

func bind_energy(energy:ResourcePoint) -> void:
	_guirp_bar.bind_with_rp(energy)
	energy.value_update.connect(func():
		_guirp_bar.animate_value_update(energy, ENERGY_UPDATE_ANIMATION_DURATION)
	)

func play_energy_full_animation() -> void:
	_audio_stream_player_2d.play()
	var tween:Tween = Util.create_scaled_tween(self)
	var delay := ENERGY_UPDATE_ANIMATION_DURATION
	var original_tint := _guirp_bar._rp_bar.tint_progress
	var flash_times := 2
	for i in flash_times:
		tween.tween_property(_guirp_bar._rp_bar, "tint_progress", Color.WHITE, ENERGY_UPDATE_ANIMATION_DURATION).set_delay(delay/2).set_ease(Tween.EASE_IN)
		tween.tween_property(_guirp_bar._rp_bar, "tint_progress", original_tint, ENERGY_UPDATE_ANIMATION_DURATION).set_delay(delay).set_ease(Tween.EASE_OUT)
		delay += ENERGY_UPDATE_ANIMATION_DURATION
	# final pause 0.1 second
	tween.tween_property(_guirp_bar._rp_bar, "tint_progress", original_tint, 0.1).set_delay((flash_times + 1) * ENERGY_UPDATE_ANIMATION_DURATION)
	tween.tween_callback(func():
		energy_full_animation_finished.emit()
	)
