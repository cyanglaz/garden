class_name CharacterBox
extends Control

@onready var _gui_character_box_detail: GUICharacterBoxDetail = %GUICharacterBoxDetail
@onready var _shake: Shake = $Shake
@warning_ignore("unused_private_class_variable")
@onready var _attacked_audio_player: AudioStreamPlayer2D = %AttackedAudioPlayer

var _attacked_count := 0

func _ready() -> void:
	pass

func bind_character(character:Character) -> void:
	_gui_character_box_detail.bind_character(character)
	character.bind_box(self)

func animate_being_attacked(character:Character, hp_change:int, time:float = 0.2, show_label:bool = true) -> void:
	_attacked_count += 1
	_attacked_audio_player.play()
	_shake.start()
	await _gui_character_box_detail.animate_being_attacked(character, hp_change, time, show_label)

func animate_restore_hp(character:Character, hp_change:int, time:float = 0.2, show_label:bool = true) -> void:
	await _gui_character_box_detail.animate_restore_hp(character, hp_change, time, show_label)

func end_damage_sequence() -> void:
	_gui_character_box_detail.end_damage_sequence()

func update_status_effects(status_effects:Array[StatusEffect]) -> void:
	_gui_character_box_detail.update_status_effects(status_effects)

func get_reference_position() -> Vector2:
	return _gui_character_box_detail.get_reference_position()

func get_icon_global_rect() -> Rect2:
	return _gui_character_box_detail.get_icon_global_rect()

func add_animating_label(text:String, color:Color, time:float) -> void:
	_gui_character_box_detail.add_animating_label(text, color, time)

func animate_value_hp(hp:ResourcePoint, time:float) -> void:
	await _gui_character_box_detail.animate_value_hp(hp, time)
