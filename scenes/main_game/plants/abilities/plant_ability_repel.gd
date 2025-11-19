class_name PlantAbilityRepel
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.START_TURN

func _trigger_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.START_TURN)
	var left_field:Field = plant.field.left_field
	var right_field:Field = plant.field.right_field
	var action_data:ActionData = ActionData.new()
	action_data.type = ActionData.ActionType.PEST
	action_data.operator_type = ActionData.OperatorType.DECREASE
	action_data.value = 1
	if left_field && left_field.plant:
		await left_field.plant.apply_actions([action_data])
	if right_field && right_field.plant:
		await right_field.plant.apply_actions([action_data])
