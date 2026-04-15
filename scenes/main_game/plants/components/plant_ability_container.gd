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
		ability_node.request_ability_hook_animation.connect(func(ability_id:String) -> void: request_ability_hook_animation.emit(ability_id))
		assert(ability_node)
		add_child(ability_node)

func trigger_ability(ability_type:Plant.AbilityType, plant:Plant, combat_main:CombatMain) -> void:
	for ability_node:PlantAbility in get_active_abilities():
		if ability_node.has_ability_hook(ability_type, plant, combat_main):
			ability_node.trigger_ability_hook(ability_type, plant)

func signal_bloom() -> void:
	for ability_node:PlantAbility in get_all_abilities():
		ability_node.active = false
	ability_updated.emit()

func get_all_abilities() -> Array:
	var abilities:Array = get_children().duplicate()
	abilities.reverse()
	return abilities
	
func get_active_abilities() -> Array:
	var abilities:Array = get_children().duplicate()
	abilities.reverse()
	abilities = abilities.filter(func(ability_node:PlantAbility) -> bool:
		return ability_node.active
	)
	return abilities
