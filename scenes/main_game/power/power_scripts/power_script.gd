@abstract
class_name PowerScript
extends RefCounted

var power_data:PowerData
var _weak_power_data:WeakRef = weakref(null)

func has_activation_hook(main_game:MainGame) -> bool:
	return _has_activation_hook(main_game)

func handle_activation_hook(main_game:MainGame) -> void:
	await _handle_activation_hook(main_game)

func has_card_added_to_hand_hook(tool_datas:Array) -> bool:
	return _has_card_added_to_hand_hook(tool_datas)

func handle_card_added_to_hand_hook(tool_datas:Array) -> void:
	await _handle_card_added_to_hand_hook(tool_datas)

#region for override

func _has_activation_hook(_main_game:MainGame) -> bool:
	return false

func _handle_activation_hook(_main_game:MainGame) -> void:
	await Util.await_for_tiny_time()

func _has_card_added_to_hand_hook(_tool_datas:Array) -> bool:
	return false

func _handle_card_added_to_hand_hook(_tool_datas:Array) -> void:
	await Util.await_for_tiny_time()

#endregion

func _set_power_data(value:PowerData) -> void:
	_weak_power_data = weakref(value)

func _get_power_data() -> PowerData:
	return _weak_power_data.get_ref()
