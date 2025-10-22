@abstract
class_name PowerScript
extends RefCounted

var power_data:PowerData
var _weak_power_data:WeakRef = weakref(null)

func has_activation_hook(combat_main:CombatMain) -> bool:
	return _has_activation_hook(combat_main)

func handle_activation_hook(combat_main:CombatMain) -> void:
	await _handle_activation_hook(combat_main)

func has_card_added_to_hand_hook(tool_datas:Array) -> bool:
	return _has_card_added_to_hand_hook(tool_datas)

func handle_card_added_to_hand_hook(tool_datas:Array) -> void:
	await _handle_card_added_to_hand_hook(tool_datas)

func has_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> bool:
	return _has_tool_application_hook(combat_main, tool_data)

func handle_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	await _handle_tool_application_hook(combat_main, tool_data)

func has_weather_application_hook(combat_main:CombatMain, weather_data:WeatherData) -> bool:
	return _has_weather_application_hook(combat_main, weather_data)

func handle_weather_application_hook(combat_main:CombatMain, weather_data:WeatherData) -> void:
	await _handle_weather_application_hook(combat_main, weather_data)

#region for override

func _has_activation_hook(_combat_main:CombatMain) -> bool:
	return false

func _handle_activation_hook(_combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_card_added_to_hand_hook(_tool_datas:Array) -> bool:
	return false

func _handle_card_added_to_hand_hook(_tool_datas:Array) -> void:
	await Util.await_for_tiny_time()

func _has_tool_application_hook(_combat_main:CombatMain, _tool_data:ToolData) -> bool:
	return false

func _handle_tool_application_hook(_combat_main:CombatMain, _tool_data:ToolData) -> void:
	await Util.await_for_tiny_time()

func _has_weather_application_hook(_combat_main:CombatMain, _weather_data:WeatherData) -> bool:
	return false

func _handle_weather_application_hook(_combat_main:CombatMain, _weather_data:WeatherData) -> void:
	await Util.await_for_tiny_time()

#endregion

func _set_power_data(value:PowerData) -> void:
	_weak_power_data = weakref(value)

func _get_power_data() -> PowerData:
	return _weak_power_data.get_ref()
