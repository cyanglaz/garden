class_name FieldStatusScriptPest
extends FieldStatusScript

func _has_ability_hook(_ability_type:Plant.AbilityType, plant:Plant) -> bool:
	return plant != null

func _handle_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> HookResultType:
	return HookResultType.ABORT
