class_name FieldStatusScriptPest
extends FieldStatusScript

func _has_harvest_hook(plant:Plant) -> bool:
	return plant != null

func _handle_harvest_hook(_plant:Plant) -> void:
	await Singletons.main_game.update_rating(-(status_data.data["value"] as int))
