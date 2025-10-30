class_name FieldStatusScriptPest
extends FieldStatusScript

func _has_harvest_hook(plant:Plant) -> bool:
	return plant != null

func _handle_harvest_hook(_plant:Plant) -> void:
	Events.request_rating_update.emit(-(status_data.data["value"] as int))
