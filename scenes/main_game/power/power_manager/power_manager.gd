class_name PowerManager
extends RefCounted

signal power_updated()
signal request_power_hook_animation(power_id:String)

var power_map:Dictionary[String, PowerData]

var _activation_hook_queue:Array[String] = []
var _current_activation_hook_index:int = 0
var _card_added_to_hand_hook_queue:Array[String] = []
var _current_card_added_to_hand_hook_index:int = 0
var _tool_application_hook_queue:Array[String] = []
var _current_tool_application_hook_index:int = 0
var _weather_application_hook_queue:Array[String] = []
var _current_weather_application_hook_index:int = 0

func clear_powers() -> void:
	power_map.clear()
	power_updated.emit()

func remove_single_turn_powers() -> void:
	for power_id in power_map.keys():
		if power_map[power_id].single_turn:
			power_map.erase(power_id)
	power_updated.emit()

func update_power(power_id:String, stack:int) -> void:
	if power_map.has(power_id):
		power_map[power_id].stack += stack
	else:
		power_map[power_id] = MainDatabase.power_database.get_data_by_id(power_id, true)
		power_map[power_id].stack = stack
	power_updated.emit()

func get_all_powers() -> Array[PowerData]:
	return power_map.values()
#region hooks

func handle_activation_hook(main_game:MainGame) -> void:
	var all_power_ids := power_map.keys()
	_activation_hook_queue = all_power_ids.filter(func(power_id:String) -> bool:
		return power_map[power_id].power_script.has_activation_hook(main_game)
	)
	_current_activation_hook_index = 0
	await _handle_next_activation_hook(main_game)

func _handle_next_activation_hook(main_game:MainGame) -> void:
	if _current_activation_hook_index >= _activation_hook_queue.size():
		return
	var power_id:String = _activation_hook_queue[_current_activation_hook_index]
	var power_data := power_map[power_id]
	_send_hook_animation_signals(power_data)
	await power_data.power_script.handle_activation_hook(main_game)
	_current_activation_hook_index += 1
	await _handle_next_activation_hook(main_game)

func handle_card_added_to_hand_hook(tool_datas:Array) -> void:
	var all_power_ids := power_map.keys()
	_card_added_to_hand_hook_queue = all_power_ids.filter(func(power_id:String) -> bool:
		return power_map[power_id].power_script.has_card_added_to_hand_hook(tool_datas)
	)
	_current_card_added_to_hand_hook_index = 0
	await _handle_next_card_added_to_hand_hook(tool_datas)

func _handle_next_card_added_to_hand_hook(tool_datas:Array) -> void:
	if _current_card_added_to_hand_hook_index >= _card_added_to_hand_hook_queue.size():
		return
	var power_id:String = _card_added_to_hand_hook_queue[_current_card_added_to_hand_hook_index]
	var power_data := power_map[power_id]
	_send_hook_animation_signals(power_data)
	await power_data.power_script.handle_card_added_to_hand_hook(tool_datas)
	_current_card_added_to_hand_hook_index += 1
	await _handle_next_card_added_to_hand_hook(tool_datas)

func _send_hook_animation_signals(power_data:PowerData) -> void:
	request_power_hook_animation.emit(power_data.id)

func handle_tool_application_hook(main_game:MainGame, tool_data:ToolData) -> void:
	var all_power_ids := power_map.keys()
	_tool_application_hook_queue = all_power_ids.filter(func(power_id:String) -> bool:
		return power_map[power_id].power_script.has_tool_application_hook(main_game, tool_data)
	)
	_current_tool_application_hook_index = 0
	await _handle_next_tool_application_hook(main_game, tool_data)

func _handle_next_tool_application_hook(main_game:MainGame, tool_data:ToolData) -> void:
	if _current_tool_application_hook_index >= _tool_application_hook_queue.size():
		return
	var power_id:String = _tool_application_hook_queue[_current_tool_application_hook_index]
	var power_data := power_map[power_id]
	_send_hook_animation_signals(power_data)
	await power_data.power_script.handle_tool_application_hook(main_game, tool_data)
	_current_tool_application_hook_index += 1
	await _handle_next_tool_application_hook(main_game, tool_data)

func handle_weather_application_hook(main_game:MainGame, weather_data:WeatherData) -> void:
	var all_power_ids := power_map.keys()
	_weather_application_hook_queue = all_power_ids.filter(func(power_id:String) -> bool:
		return power_map[power_id].power_script.has_weather_application_hook(main_game, weather_data)
	)
	_current_weather_application_hook_index = 0
	await _handle_next_weather_application_hook(main_game, weather_data)

func _handle_next_weather_application_hook(main_game:MainGame, weather_data:WeatherData) -> void:
	if _current_weather_application_hook_index >= _weather_application_hook_queue.size():
		return
	var power_id:String = _weather_application_hook_queue[_current_weather_application_hook_index]
	var power_data := power_map[power_id]
	_send_hook_animation_signals(power_data)
	await power_data.power_script.handle_weather_application_hook(main_game, weather_data)
	_current_weather_application_hook_index += 1
	await _handle_next_weather_application_hook(main_game, weather_data)
#endregion
