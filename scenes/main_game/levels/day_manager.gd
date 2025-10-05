class_name DayManager
extends RefCounted

var day:int = 0

func start_new(contract:ContractData) -> void:
	day = -1

func next_day() -> void:
	day += 1
