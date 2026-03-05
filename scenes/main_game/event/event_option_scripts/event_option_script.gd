class_name EventOptionScript
extends RefCounted

@warning_ignore("unused_signal")
signal request_add_sub_scene(sub_scene:Node)

func run(option_data:EventOptionData, main_game:MainGame) -> Variant:
	return await _run(option_data, main_game)

func should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	return _should_enable(option_data,main_game)

func prepare(event_data:EventData, main_game:MainGame, option_data:EventOptionData) -> void:
	_prepare(event_data, main_game, option_data)

func _run(_option_data:EventOptionData, _main_game:MainGame) -> Variant:
	await Util.await_for_tiny_time()
	return null

func _should_enable(_option_data:EventOptionData, _main_game:MainGame) -> bool:
	return true

func _prepare(_event_data:EventData, _main_game:MainGame, _option_data:EventOptionData) -> void:
	pass
