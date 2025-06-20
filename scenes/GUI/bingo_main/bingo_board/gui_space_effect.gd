class_name GUISpaceEffect
extends TextureRect

const TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_space_effect_tooltip.tscn")
const ANIMATION_OFFSET := 2.0

signal trigger_animation_finished()

@export var tooltip_position:GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.RIGHT
@onready var _stack: Label = %Stack
@onready var _trigger_sound: AudioStreamPlayer2D = %TriggerSound

var _weak_tooltip:WeakRef = weakref(null)
var _weak_space_effect:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)

func bind_with_space_effect(space_effect:SpaceEffect) -> void:
	_weak_space_effect = weakref(space_effect)
	space_effect.gui_space_effect = self
	texture = load(Util.get_image_path_for_space_effect_id(space_effect.data.id))
	if space_effect.data.show_stack:
		_stack.text = str(space_effect.stack)
		_stack.show()
	else:
		_stack.hide()

func animate_trigger(time:float) -> void:
	_trigger_sound.play()
	var original_position:Vector2 = position
	var tween:Tween = create_tween()
	for i in 2:
		tween.tween_property(self, "position", original_position + Vector2.UP * ANIMATION_OFFSET, time/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", original_position, time/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	trigger_animation_finished.emit()

func _on_mouse_entered() -> void:
	_weak_tooltip = weakref(Util.display_space_effect_tooltip(_weak_space_effect.get_ref(), self, true, tooltip_position))
