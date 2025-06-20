class_name MinionManager
extends RefCounted

signal minions_updated()

var attack_counters:Dictionary = {}
var minion_datas:Array[BingoBallData] = []

var _gui_minion_box:GUIMinionBox: get = _get_gui_minion_box
var _weak_gui_minion_box:WeakRef = weakref(null)

func bind_ui(gui_minion_box:GUIMinionBox) -> void:
	assert(_weak_gui_minion_box.get_ref() == null)
	_weak_gui_minion_box = weakref(gui_minion_box)

func set_initial_minions(datas:Array[BingoBallData]) -> void:
	for minion_data:BingoBallData in datas:
		add_minion(minion_data.get_duplicate())

func add_minion(minion_data:BingoBallData) -> void:
	#assert(minion_data.type == BingoBallData.Type.MINION)
	assert(not attack_counters.has(minion_data.base_id))
	assert(not minion_datas.has(minion_data))
	minion_datas.append(minion_data)
	var counter:ResourcePoint = ResourcePoint.new()
	counter.setup(0, minion_data.attack_ball_count)
	attack_counters[minion_data.base_id] = counter
	minions_updated.emit()

func remove_minion(minion_data:BingoBallData) -> void:
	minion_datas.erase(minion_data)
	attack_counters.erase(minion_data.base_id)
	minions_updated.emit()
	
func animate_increase_attack_counters(value:int, time:float = 0.2) -> Array:
	var result:Array = _restore_attack_counters(value)
	_gui_minion_box.animate_update_attack_counters(attack_counters, time)
	return result

func animate_decrease_attack_counters(value:int, time:float = 0.2) -> void:
	_spend_attack_counters(value)
	_gui_minion_box.animate_update_attack_counters(attack_counters, time)

func animate_reset_all_attack_counters(time:float = 0.2) -> void:
	for ball_data:BingoBallData in minion_datas:
		animate_reset_attack_counter(ball_data.base_id, time)

func animate_reset_attack_counter(id:String, time:float = 0) -> void:
	attack_counters[id].value = 0
	_gui_minion_box.animate_update_attack_counter(id, attack_counters[id], time)

func _restore_attack_counters(value:int) -> Array:
	var final_result:Array = []
	for ball_data_base_id:String in attack_counters.keys():
		var result := []
		var attack_counter:ResourcePoint = attack_counters[ball_data_base_id]
		attack_counter.restore(value)
		if attack_counter.value >= attack_counter.max_value:
			var attacking_ball_index := Util.array_find(minion_datas, func(ball_data:BingoBallData): return ball_data.base_id == ball_data_base_id)
			var attack_ball_data:BingoBallData = minion_datas[attacking_ball_index]
			for i in attack_ball_data.attack_ball_count:
				result.append(attack_ball_data.get_duplicate())
		if !result.is_empty():
			final_result.append(result)
	return final_result

func _spend_attack_counters(value:int) -> void:
	for attack_counter in attack_counters.values():
		attack_counter.spend(value)

func _get_gui_minion_box() -> GUIMinionBox:
	return _weak_gui_minion_box.get_ref()
