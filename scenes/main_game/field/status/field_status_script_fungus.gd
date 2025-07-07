class_name FieldStatusScriptFungus
extends FieldStatusScript

func _has_harvest_gold_hook() -> bool:
	return true

func _handle_harvest_gold_hook(plant:Plant) -> void:
	plant.data.gold = int(plant.data.gold * 0.5)
