class_name PlantAbilityContainer
extends Node2D

signal ability_updated()
signal request_ability_hook_animation(ability_id:String)

func setup_with_plant_data(plant_data:PlantData) -> void:
	for plant_ability_id:String in plant_data.abilities.keys():
		var plant_ability_stack:int = (plant_data.abilities[plant_ability_id] as int)
		var plant_ability_data:PlantAbilityData = MainDatabase.plant_ability_database.get_data_by_id(plant_ability_id)
		var ability_node:PlantAbility = load(plant_ability_data.get_ability_path()).instantiate()
		ability_node.ability_data = plant_ability_data
		ability_node.stack = plant_ability_stack
		ability_node.current_cooldown = plant_ability_data.cooldown
		assert(ability_node)
		add_child(ability_node)

func clear_all_abilities() -> void:
	for ability_node:PlantAbility in get_abilities():
		remove_child(ability_node)
		ability_node.queue_free()
	ability_updated.emit()

func trigger_ability(ability_type:Plant.AbilityType, plant:Plant) -> void:
	for ability_node:PlantAbility in get_children():
		if ability_node.has_ability_hook(ability_type, plant):
			request_ability_hook_animation.emit(ability_node.ability_data.id)
			await ability_node.trigger_ability_hook(ability_type, plant)

func signal_bloom() -> void:
	for ability_node:PlantAbility in get_abilities():
		ability_node.active = false
	
func get_abilities() -> Array:
	var abilities:Array = get_children().duplicate()
	abilities.reverse()
	return abilities
