class_name PowerManager
extends RefCounted

signal updated()

var max_powers := 0
var powers:Array[PowerData] = []

func _init(player_data:PlayerData) -> void:
	for data:PowerData in player_data.powers:
		add_power(data)
	max_powers = player_data.max_powers

func reset_all_cd_counters() -> void:
	for power:PowerData in powers:
		reset_cd_counter(power)

func update_cd_counter(update:int) -> void:
	for power:PowerData in powers:
		if power.cd_counter < power.cd:
			power.cd_counter += update

func reset_cd_counter(power_data:PowerData) -> void:
	power_data.cd_counter = 0

func add_power(data:PowerData) -> void:
	assert(not powers.has(data))
	powers.append(data.get_duplicate())
	updated.emit()

func remove_power(data:PowerData) -> void:
	for power:PowerData in powers:
		if power.base_id == data.base_id:
			powers.erase(power)
			updated.emit()
			return
	assert(false)
