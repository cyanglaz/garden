class_name PlantAbilityRepel
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType) -> bool:
	return ability_type == Plant.AbilityType.FIELD_STATUS_UPDATE

func _trigger_ability_hook(ability_type:Plant.AbilityType, _main_game:MainGame, plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.FIELD_STATUS_UPDATE)
	var pest_stack := plant.field.status_manager.get_status("pest").stack
	if pest_stack > 0:
		await plant.field.apply_field_status("pest", -pest_stack)
