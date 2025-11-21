class_name PlantAbilityContainer
extends Node2D

signal request_ability_hook_animation(ability_id:String)

func setup_with_plant_data(plant_data:PlantData) -> void:
	for ability_id:String in plant_data.abilities:
		var ability_data :PlantAbilityData = MainDatabase.plant_ability_database.get_data_by_id(ability_id)
		var ability_path := ability_data.get_ability_path()
		var ability_node:PlantAbility = load(ability_path).instantiate()
		ability_node.ability_data = ability_data
		assert(ability_node)
		add_child(ability_node)

func trigger_ability(ability_type:Plant.AbilityType, plant:Plant) -> void:
	for ability_node:PlantAbility in get_children():
		if ability_node.has_ability_hook(ability_type, plant):
			request_ability_hook_animation.emit(ability_node.ability_data.id)
			await ability_node.trigger_ability_hook(ability_type, plant)
	