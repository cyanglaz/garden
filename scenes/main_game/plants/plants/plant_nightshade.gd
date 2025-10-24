class_name PlantNightshade
extends Plant

#func _has_ability(ability_type:AbilityType) -> bool:
#	return ability_type == AbilityType.HARVEST

#func _trigger_ability(ability_type:AbilityType, _main_game:MainGame) -> void:
#	assert(ability_type == AbilityType.HARVEST)
#	var adjacent_fields := _find_adjacent_fields()
#	var pest_stack := 0
#	for adjacent_field:Field in adjacent_fields:
#		pest_stack += adjacent_field.status_manager.get_status("pest").stack
#	await Singletons.main_game.update_gold(pest_stack, true)
#	ability_triggered.emit(ability_type)

#func _find_adjacent_fields() -> Array[Field]:
#	var result:Array[Field] = []
#	if field.weak_left_field.get_ref():
#		result.append(field.weak_left_field.get_ref())
#	if field.weak_right_field.get_ref():
#		result.append(field.weak_right_field.get_ref())
#	return result
