class_name PlantAbility
extends Node2D

signal cooldown_updated(cooldown:int)
signal request_ability_hook_animation(ability_id:String)

var ability_data:PlantAbilityData
var stack:int = 0
var current_cooldown:int = 0: set = _set_current_cooldown
var active:bool = true

func has_ability_hook(ability_type:Plant.AbilityType, plant:Plant, combat_main:CombatMain) -> bool:
	if not active:
		return false
	if current_cooldown > 0:
		if ability_type == Plant.AbilityType.START_TURN:
			current_cooldown -= 1
		return false
	return _has_ability_hook(ability_type, plant, combat_main)

func queue_trigger_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	if not active:
		return
	var request = CombatQueueRequest.new()
	match ability_type:
		Plant.AbilityType.START_TURN:
			request.front = false
		Plant.AbilityType.END_TURN:
			request.front = false
		Plant.AbilityType.BLOOM:
			request.front = true
			request.front_group = "bloom"
	request.callback = func(cm:CombatMain) -> void: await _handle_trigger_ability_hook(ability_type, plant, cm)
	Events.request_combat_queue_push.emit(request)

func _handle_trigger_ability_hook(ability_type:Plant.AbilityType, plant:Plant, combat_main:CombatMain) -> void:
	request_ability_hook_animation.emit(ability_data.id)
	await _trigger_ability_hook(ability_type, plant, combat_main)
	current_cooldown = ability_data.cooldown

#region for override

func _has_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant, _combat_main:CombatMain) -> bool:
	return false

func _trigger_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant, _combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

#endregion

func _set_current_cooldown(value:int) -> void:
	current_cooldown = value
	cooldown_updated.emit(value)
