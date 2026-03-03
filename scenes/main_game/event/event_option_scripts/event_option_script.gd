class_name EventOptionScript
extends RefCounted

func run(option_data:EventOptionData) -> void:
	await _run(option_data)

func should_enable(option_data:EventOptionData, main_game:MainGame) -> bool:
	return _should_enable(option_data,main_game)

func _run(_option_data:EventOptionData) -> void:
	await Util.await_for_tiny_time()

func _should_enable(_option_data:EventOptionData, _main_game:MainGame) -> bool:
	return true
