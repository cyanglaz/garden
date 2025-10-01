class_name DayManager
extends RefCounted

var day:int = 0
var grace_period_last_day:int = 0

func start_new(contract:ContractData) -> void:
	grace_period_last_day = contract.grace_period - 1
	day = -1

func next_day() -> void:
	day += 1

func get_grace_period_day_left() -> int:
	return grace_period_last_day - day
