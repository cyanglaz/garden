class_name PlantAbility
extends Node2D

signal cooldown_updated(cooldown:int)
signal request_ability_hook_animation(ability_id:String)

var ability_data:PlantAbilityData
var stack:int = 0
var current_cooldown:int = 0: set = _set_current_cooldown

func has_ability_hook(ability_type:Plant.AbilityType, plant:Plant, combat_main:CombatMain) -> bool:
	if current_cooldown > 0:
		if ability_type == Plant.AbilityType.START_TURN:
			current_cooldown -= 1
		return false
	return _has_ability_hook(ability_type, plant, combat_main)

func trigger_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	var request = CombatQueueRequest.new()
	request.front = true
	request.callback = func(cm:CombatMain) -> void: _handle_trigger_ability_hook(ability_type, plant, cm)
	Events.request_combat_queue_push.emit(request)

func _handle_trigger_ability_hook(ability_type:Plant.AbilityType, plant:Plant, combat_main:CombatMain) -> void:
	request_ability_hook_animation.emit(ability_data.id)
	_trigger_ability_hook(ability_type, plant, combat_main)
	current_cooldown = ability_data.cooldown

#region for override

func _has_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant, _combat_main:CombatMain) -> bool:
	return false

func _trigger_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant, _combat_main:CombatMain) -> void:
	pass

#endregion

func _set_current_cooldown(value:int) -> void:
	current_cooldown = value
	cooldown_updated.emit(value)
