class_name GUIStatusEffect
extends TextureRect

signal animation_finished()

const TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_status_effect_tooltip.tscn")

@export var tooltip_position:GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.RIGHT
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _buff_audio: AudioStreamPlayer2D = %BuffAudio

@onready var _attack_count: Label = %AttackCount

var _weak_tooltip:WeakRef = weakref(null)
var _weak_status_effect:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)

func bind_with_status_effect(status_effect:StatusEffect) -> void:
	status_effect.gui_status_effect = self
	_weak_status_effect = weakref(status_effect)
	texture = load(Util.get_image_path_for_status_effect_id(status_effect.data.id))
	_attack_count.text = str(status_effect.stack)
	if status_effect.stack > 0:
		_attack_count.self_modulate = Constants.COLOR_GREEN3
	else:
		_attack_count.self_modulate = Constants.COLOR_RED2

func play_animation() -> void:
	_buff_audio.play()
	_animation_player.play("buff")
	await _animation_player.animation_finished
	animation_finished.emit()

func _on_mouse_entered() -> void:
	_weak_tooltip = weakref(Util.display_status_effect_tooltip(_weak_status_effect.get_ref().data, self, true, tooltip_position))
	
