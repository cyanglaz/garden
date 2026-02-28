class_name GUIHP
extends PanelContainer

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")
const SEGMENT_SCENE := preload("res://scenes/GUI/main_game/top_bar/gui_hp_segment.tscn")

const HP_SAFE_COLOR := Constants.COLOR_RED1
const HP_MODERATE_COLOR := Constants.COLOR_RED2
const HP_DANGER_COLOR := Constants.COLOR_RED3
const HP_MODERATE_PERCENTAGE := 0.6
const HP_DANGER_PERCENTAGE := 0.2
#const POPUP_SHOW_TIME := 0.5
#const POPUP_DESTROY_TIME := 0.5
const SHAKE_TIMES := 2
const TEXTURE_SHAKE_DISTANCE := 1

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _up_sound: AudioStreamPlayer2D = %UpSound
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _segment_container: GridContainer = %SegmentContainer
@onready var _label: Label = %Label

var _current_value:int = -1

func bind_with_hp(hp:ResourcePoint) -> void:
	hp.value_update.connect(_on_hp_value_update.bind(hp))
	hp.max_value_update.connect(_on_hp_max_value_update.bind(hp))
	_on_hp_max_value_update(hp)
	_on_hp_value_update(hp)

func animate_hp_update(value:int) -> void:
	await _play_animation(value)

func _on_hp_max_value_update(hp:ResourcePoint) -> void:
	Util.remove_all_children(_segment_container)
	for i in hp.max_value:
		var segment:GUIHPSegment = SEGMENT_SCENE.instantiate()
		_segment_container.add_child(segment)

func _on_hp_value_update(hp:ResourcePoint) -> void:
	if _current_value >= 0:
		var diff = hp.value - _current_value
		if diff == 0:
			return
	_current_value = hp.value
	var tint_color:Color = HP_SAFE_COLOR
	var percentage:float = (hp.value as float) / hp.max_value
	if percentage >= HP_MODERATE_PERCENTAGE:
		tint_color = HP_SAFE_COLOR
	elif percentage >= HP_DANGER_PERCENTAGE:
		tint_color = HP_MODERATE_COLOR
	else:
		tint_color = HP_DANGER_COLOR
	_label.text = str(hp.value, "/", hp.max_value)
	for i in range(hp.max_value):
		if i < hp.value:
			_segment_container.get_child(i).is_empty = false
			_segment_container.get_child(i).modulate = tint_color
		else:
			_segment_container.get_child(i).is_empty = true
			_segment_container.get_child(i).modulate = Constants.COLOR_WHITE

func _play_animation(diff:int) -> void:
	#var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	#popup.bump_direction = PopupThing.BumpDirection.DOWN
	#var color:Color = Player.HP_DECREASE_COLOR
	var increase := diff > 0
	#if increase:
	#	color = Player.HP_INCREASE_COLOR
	#else:
	#	color = Player.HP_DECREASE_COLOR
	#var hp_sign := "+" if increase else ""
	#popup.setup(str(hp_sign, diff), color, 10)
	#Events.request_display_popup_things.emit(popup, -20, 5, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, _segment_container.global_position + Vector2.RIGHT * _segment_container.size.x)
	if increase:
		await _play_hp_increase_animation()
	elif diff < 0:
		await _play_hp_drop_animation()

func _play_hp_drop_animation() -> void:
	if _animation_player.is_playing():
		_animation_player.stop()
	_animation_player.play("hp_drop")
	await _animation_player.animation_finished

func _play_hp_increase_animation() -> void:
	_up_sound.play()
	_texture_rect.pivot_offset_ratio = Vector2.ONE * 0.5
	var _texture_rect_position:Vector2 = _texture_rect.position
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(_texture_rect, "scale", Vector2.ONE * 1.5, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_texture_rect, "position", _texture_rect_position + Vector2.UP, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_texture_rect, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(0.2)
	tween.tween_property(_texture_rect, "position", _texture_rect_position, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(0.2)
	await tween.finished
