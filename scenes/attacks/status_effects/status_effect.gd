class_name StatusEffect
extends RefCounted

signal handle_finished()

var data:StatusEffectData
var stack:int = 1
var character_owner:Character: get = _get_character_owner
var gui_status_effect:GUIStatusEffect: get = _get_gui_status_effect, set = _set_gui_status_effect

var _weak_gui_status_effect:WeakRef = weakref(null)

var _weak_owner:WeakRef = weakref(null)

func _init(d:StatusEffectData, s:int, co:Character) -> void:
	stack = s
	data = d
	_weak_owner = weakref(co)

func handle_predraw() -> void:
	if _has_predraw_effect():
		play_animation()
		await handle_finished

func handle_bingo(bingo_result:BingoResult) -> void:
	if _has_bingo_effect(bingo_result):
		play_animation()
		await handle_finished

func on_cleared() -> void:
	pass

#region private

func play_animation() -> void:
	gui_status_effect.play_animation()

#endregion

#region checks
func _has_predraw_effect() -> bool:
	return false

func _has_bingo_effect(_bingo_result:BingoResult) -> bool:
	return false

#endregion

#region getters and setters

func _get_character_owner() -> Character:
	return _weak_owner.get_ref()

func _get_gui_status_effect() -> GUIStatusEffect:
	return _weak_gui_status_effect.get_ref()

func _set_gui_status_effect(value:GUIStatusEffect) -> void:
	_weak_gui_status_effect = weakref(value)
	gui_status_effect.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	pass

#endregion
