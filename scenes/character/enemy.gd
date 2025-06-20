class_name Enemy
extends Character

signal combat_state_changed(combat_state:CombatState)

enum CombatState {
	INACTIVE,
	ACTIVE,
	DEAD
}

var combat_state:CombatState = CombatState.INACTIVE: set = _set_combat_state

var attack_counters:Dictionary = {}
var attacks:Array[BingoBallData] = []

func _init(d:CharacterData) -> void:
	super._init(d)
	for ball_data:BingoBallData in data.initial_balls:
		attacks.append(ball_data.get_duplicate())
	for ball_data:BingoBallData in attacks:
		ball_data.owner = self
		attack_counters[ball_data.base_id] = ResourcePoint.new()
		attack_counters[ball_data.base_id].setup(0, ball_data.attack_speed)

func animate_increase_attack_counters(value:int, time:float = 0.2) -> Array:
	var result:Array = _restore_attack_counters(value)
	(_box as GUIEnemyBox).animate_update_attack_counters(attack_counters, time)
	return result

func animate_decrease_attack_counters(value:int, time:float = 0.2) -> void:
	_spend_attack_counters(value)
	(_box as GUIEnemyBox).animate_update_attack_counters(attack_counters, time)

func animate_reset_all_attack_counters(time:float = 0.2) -> void:
	for ball_data:BingoBallData in attacks:
		animate_reset_attack_counter(ball_data.base_id, time)

func animate_reset_attack_counter(id:String, time:float = 0) -> void:
	attack_counters[id].value = 0
	await (_box as GUIEnemyBox).animate_update_attack_counter(id, attack_counters[id], time)

func _restore_attack_counters(value:int) -> Array:
	var final_result:Array = []
	for ball_data_base_id:String in attack_counters.keys():
		var result := []
		var attack_counter:ResourcePoint = attack_counters[ball_data_base_id]
		attack_counter.restore(value)
		if attack_counter.value >= attack_counter.max_value:
			var attacking_ball_index := Util.array_find(attacks, func(ball_data:BingoBallData): return ball_data.base_id == ball_data_base_id)
			var attack_ball_data:BingoBallData = attacks[attacking_ball_index]
			for i in attack_ball_data.attack_ball_count:
				result.append(attack_ball_data)
		if !result.is_empty():
			final_result.append(result)
	return final_result

func _spend_attack_counters(value:int) -> void:
	for attack_counter in attack_counters.values():
		attack_counter.spend(value)

func _set_is_died(value:bool) -> void:
	super._set_is_died(value)
	combat_state = CombatState.DEAD

func _set_combat_state(val:CombatState) -> void:
	combat_state = val
	combat_state_changed.emit(combat_state)
