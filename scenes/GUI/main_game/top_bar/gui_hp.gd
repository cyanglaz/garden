class_name GUIHP
extends HBoxContainer

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")

signal hp_update_finished(value:int)

const HP_SAFE_COLOR := Constants.COLOR_RED1
const HP_MODERATE_COLOR := Constants.COLOR_RED2
const HP_DANGER_COLOR := Constants.COLOR_RED3
const HP_SAFE_TEXT_COLOR := Constants.COLOR_WHITE
const HP_MODERATE_TEXT_COLOR := Constants.COLOR_RED1
const HP_DANGER_TEXT_COLOR := Constants.COLOR_RED2
const HP_INCREASE_COLOR := Constants.COLOR_RED1
const HP_DECREASE_COLOR := Constants.COLOR_RED3
const HP_MODERATE_PERCENTAGE := 0.6
const HP_DANGER_PERCENTAGE := 0.2
const POPUP_SHOW_TIME := 0.5
const POPUP_DESTROY_TIME := 0.5
const SHAKE_TIMES := 2
const TEXTURE_SHAKE_DISTANCE := 1

@onready var gui_bordered_progress_bar: GUIProgressBar = %GUIBorderedProgressBar
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _up_sound: AudioStreamPlayer2D = %UpSound
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var _current_value:int = -1

func _ready() -> void:
	gui_bordered_progress_bar.animate_set_value_finished.connect(func(value:int): hp_update_finished.emit(value))

func bind_with_hp(hp:ResourcePoint) -> void:
	hp.value_update.connect(_on_hp_value_update.bind(hp))
	hp.max_value_update.connect(_on_hp_value_update.bind(hp))
	_on_hp_value_update(hp)

func _on_hp_value_update(hp:ResourcePoint) -> void:
	gui_bordered_progress_bar.max_value = hp.max_value
	if _current_value >= 0:
		var diff = hp.value - _current_value
		if diff == 0:
			await Util.await_for_tiny_time()
			hp_update_finished.emit(hp.value)
			return
		_play_animation(diff)
	_current_value = hp.value
	gui_bordered_progress_bar.animated_set_value(hp.value)
	var tint_color:Color = HP_SAFE_COLOR
	var text_color:Color = HP_SAFE_TEXT_COLOR
	var percentage:float = (hp.value as float) / hp.max_value
	if percentage >= HP_MODERATE_PERCENTAGE:
		tint_color = HP_SAFE_COLOR
		text_color = HP_SAFE_TEXT_COLOR
	elif percentage >= HP_DANGER_PERCENTAGE:
		tint_color = HP_MODERATE_COLOR
		text_color = HP_MODERATE_TEXT_COLOR
	else:
		tint_color = HP_DANGER_COLOR
		text_color = HP_DANGER_TEXT_COLOR
	rich_text_label.text = str("[color=", Util.get_color_hex(text_color), "]", hp.value, "/", hp.max_value, "[/color]")
	gui_bordered_progress_bar.tint_progress = tint_color

func _play_animation(diff:int) -> void:
	var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	var color:Color = HP_DECREASE_COLOR
	if diff > 0:
		color = HP_INCREASE_COLOR
		_play_hp_increase_animation()
	elif diff < 0:
		_play_hp_drop_animation()
		color = HP_DECREASE_COLOR
	popup.setup(str(diff), color, 10)
	Events.request_display_popup_things.emit(popup, -10, 10, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, gui_bordered_progress_bar.global_position + Vector2.RIGHT * gui_bordered_progress_bar.size.x)

func _play_hp_drop_animation() -> void:
	if _animation_player.is_playing():
		_animation_player.stop()
	_animation_player.play("hp_drop")
	await _animation_player.animation_finished

func _play_hp_increase_animation() -> void:
	_up_sound.play()
	_texture_rect.pivot_offset = _texture_rect.size/2
	var _texture_rect_position:Vector2 = _texture_rect.position
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(_texture_rect, "scale", Vector2.ONE * 1.5, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_texture_rect, "position", _texture_rect_position + Vector2.UP, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_texture_rect, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(0.2)
	tween.tween_property(_texture_rect, "position", _texture_rect_position, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(0.2)
	await tween.finished
