class_name FieldStatusScriptFungus
extends FieldStatusScript

func _has_harvest_ability_hook() -> bool:
	return true

func _handle_harvest_ability_hook(plant:Plant) -> HookResultType:
	plant.data.gold = int(plant.data.gold * 0.5)
	return HookResultType.PASS
