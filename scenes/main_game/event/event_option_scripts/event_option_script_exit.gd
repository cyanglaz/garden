class_name EventOptionScriptExit
extends EventOptionScript

func _run(_option_data:EventOptionData) -> Variant:
	await Util.await_for_tiny_time()
	return null
