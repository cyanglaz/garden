class_name TrinketGlobalScriptParasiticVine
extends TrinketGlobalScript

func _has_on_collect_hook() -> bool:
	return true

func handle_on_collect_hook() -> void:
	Events.request_max_hp_update.emit(int(trinket_data.data[&"max_hp"]), ActionData.OperatorType.DECREASE)
