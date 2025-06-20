class_name GUICharacterBoxDetail
extends Control

const STATUS_EFFECT_SCENE := preload("res://scenes/GUI/bingo_main/character_boxes/components/gui_status_effect.tscn")

@onready var _gui_character_icon: GUICharacterIcon = %GUICharacterIcon
@onready var _gui_hp_bar: GUIHPBar = %GUIHPBar
@onready var _name_label: Label = %NameLabel
@onready var _status_effects_container: HBoxContainer = %StatusEffectsContainer

func bind_character(character:Character) -> void:
	_name_label.text = character.data.display_name
	_gui_character_icon.bind_character(character.data)
	_gui_hp_bar.bind_with_character(character)

func end_damage_sequence() -> void:
	_gui_hp_bar.destroy_total_damage_label()

func animate_being_attacked(character:Character, hp_change:int, time:float, show_label:bool = true) -> void:
	_gui_character_icon.animate_being_attacked()
	if show_label:
		_gui_hp_bar.add_animating_label(hp_change, time)
	await _gui_hp_bar.animate_value_hp(character.hp, time)

func animate_restore_hp(character:Character, hp_change:int, time:float, show_label:bool = true) -> void:
	if show_label:
		_gui_hp_bar.add_animating_label(hp_change, time)
	await _gui_hp_bar.animate_value_hp(character.hp, time)

func get_reference_position() -> Vector2:
	return _gui_character_icon.global_position

func update_status_effects(status_effects:Array[StatusEffect]) -> void:
	Util.remove_all_children(_status_effects_container)
	for status_effect:StatusEffect in status_effects:
		var gui_status_effect:GUIStatusEffect = STATUS_EFFECT_SCENE.instantiate()
		_status_effects_container.add_child(gui_status_effect)
		gui_status_effect.bind_with_status_effect(status_effect)

func animate_value_hp(hp:ResourcePoint, time:float) -> void:
	await _gui_hp_bar.animate_value_hp(hp, time)

func get_icon_global_rect() -> Rect2:
	return _gui_character_icon.get_global_rect()

func get_icon() -> GUICharacterIcon:
	return _gui_character_icon
