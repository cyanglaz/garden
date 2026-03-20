class_name PlayerTrinketNectarHeart
extends PlayerTrinket

func _has_collect_hook() -> bool:
	return true

func _handle_collect_hook() -> void:
	Events.request_max_hp_update.emit(int(data.data[&"max_hp"]), ActionData.OperatorType.INCREASE)
