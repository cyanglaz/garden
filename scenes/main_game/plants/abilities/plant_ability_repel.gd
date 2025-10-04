class_name PlantAbilityRepel
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _main_game:MainGame, plant:Plant) -> bool:
	if (ability_type != Plant.AbilityType.FIELD_STATUS_INCREASE && ability_type != Plant.AbilityType.ON_PLANT):
		return false
	var pest_data := plant.field.status_manager.get_status("pest")
	if pest_data:
		var pest_stack := pest_data.stack
		if pest_stack > 0:
			return true
	return false

func _trigger_ability_hook(ability_type:Plant.AbilityType, _main_game:MainGame, plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.FIELD_STATUS_INCREASE || ability_type == Plant.AbilityType.ON_PLANT)
	var pest_data := plant.field.status_manager.get_status("pest")
	assert(pest_data, "Pest data not found")
	var pest_stack := pest_data.stack
	assert(pest_stack > 0, "Pest stack is not greater than 0")
	await plant.field.apply_field_status("pest", -pest_stack)
