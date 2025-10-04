class_name PlantAbilityManager
extends RefCounted

signal request_ability_hook_animation(ability_id:String)

func trigger_ability(ability_type:Plant.AbilityType, main_game:MainGame, plant:Plant) -> void:
	for ability_data:PlantAbilityData in plant.data.abilities:
		if ability_data.ability_script.has_ability_hook(ability_type, main_game, plant):
			request_ability_hook_animation.emit(ability_data.id)
			await ability_data.ability_script.trigger_ability_hook(ability_type, main_game, plant)
