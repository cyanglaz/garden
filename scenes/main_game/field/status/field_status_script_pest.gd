class_name FieldStatusScriptPest
extends FieldStatusScript

func _has_end_turn_hook(_plant:Plant) -> bool:
	return true

func _handle_end_turn_hook(_combat_main:CombatMain, _plant:Plant) -> void:
	Events.request_hp_update.emit(-(status_data.data["value"] as int))
