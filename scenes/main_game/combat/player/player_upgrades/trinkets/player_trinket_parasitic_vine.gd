class_name PlayerTrinketParasiticVine
extends PlayerTrinket

func _has_plant_bloom_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_plant_bloom_hook(_combat_main: CombatMain) -> void:
	_send_hook_animation_signals()
	Events.request_hp_update.emit(int(data.data[&"hp"]), ActionData.OperatorType.INCREASE)
