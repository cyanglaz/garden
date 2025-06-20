class_name GUIEnemyBox
extends CharacterBox

const VERTICAL_ATTACK_BAR_PADDING := 1
const HORIZONTAL_ATTACK_BAR_PADDING := 1

const ANIMATION_DURATION:float = 0.2
const ATTACK_BAR_SCENE := preload("res://scenes/GUI/bingo_main/character_boxes/components/gui_enemy_attack_bar.tscn")

const CHARACTER_ICON_SCENE := preload("res://scenes/GUI/bingo_main/character_boxes/components/gui_character_icon.tscn")

@onready var _death_audio: AudioStreamPlayer2D = %DeathAudio
@onready var _appear_audio: AudioStreamPlayer2D = %AppearAudio
@onready var _gui_enemy_detail_animator: GUIEnemyBoxDetail = %GUIEnemyDetailAnimator
@onready var _animation_container: Control = %AnimationContainer

var enemy:Enemy: get = _get_enemy
var _weak_enemy:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	_gui_enemy_detail_animator.hide()
	#_gui_enemy_detail_animator.z_index = 1
	custom_minimum_size = _gui_character_box_detail.size

func bind_character(character:Character) -> void:
	super.bind_character(character)
	_gui_enemy_detail_animator.bind_character(character)
	_weak_enemy = weakref(character as Enemy)

func get_attack_bingo_ball(bingo_ball_data:BingoBallData) -> GUIBingoBall:
	return _gui_character_box_detail.get_attack_bingo_ball(bingo_ball_data)

func clear_warnings() -> void:
	_gui_character_box_detail.clear_warnings()

func animate_update_attack_counters(attack_counters:Dictionary, time:float = 0.2) -> void:
	_gui_character_box_detail.animate_update_attack_counters(attack_counters, time)

func animate_update_attack_counter(id:String, attack_counter:ResourcePoint, time:float) -> void:
	await _gui_character_box_detail.animate_update_attack_counter(id, attack_counter, time)

func get_attack_bars() -> Dictionary:
	return (_gui_character_box_detail as GUIEnemyBoxDetail)._attack_bars

func animate_death() -> void:
	hide_all.call_deferred()
	_gui_enemy_detail_animator.show()
	_gui_enemy_detail_animator.bind_character(enemy)
	_gui_enemy_detail_animator.position = Vector2.ONE
	_shake.start(0.6)
	_death_audio.play()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(_gui_enemy_detail_animator, "position", Vector2(100, 150), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	_gui_enemy_detail_animator.hide()
	# _gui_character_box_detail.show()

func animate_appear() -> void:
	hide_all.call_deferred()
	_gui_enemy_detail_animator.position = Vector2(100, 0)
	_gui_enemy_detail_animator.bind_character(enemy)
	_gui_enemy_detail_animator.show()
	_appear_audio.play()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(_gui_enemy_detail_animator, "position", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_interval(0.2)
	await tween.finished
	_gui_enemy_detail_animator.hide()
	_gui_character_box_detail.show()

func animate_appear_from_bench(icon_global_rect:Rect2) -> void:
	hide_all.call_deferred()
	_appear_audio.play()
	var icon := CHARACTER_ICON_SCENE.instantiate()
	#icon.z_index = 1
	_animation_container.add_child(icon)
	icon.size = icon_global_rect.size
	icon.bind_character(enemy.data)
	icon.global_position = icon_global_rect.position
	var final_global_position := _gui_character_box_detail.get_icon_global_rect().position
	var final_size := _gui_character_box_detail.get_icon_global_rect().size
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(icon, "global_position", final_global_position, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.set_parallel(true).tween_property(icon, "size", final_size, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_interval(0.2)
	await tween.finished
	_show_all()
	icon.queue_free()

func hide_all() -> void:
	custom_minimum_size = _gui_character_box_detail.size
	_gui_character_box_detail.hide()

func _show_all() -> void:
	_gui_character_box_detail.show()

#region getters

func _get_enemy() -> Enemy:
	return _weak_enemy.get_ref()

#endregion
