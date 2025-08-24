class_name DayManager
extends RefCounted

var day:int = 0
var max_days:int = 0

func start_new(level_data:LevelData) -> void:
	max_days = level_data.number_of_days
	day = -1

func next_day() -> void:
	day += 1

func get_day_left() -> int:
	return max_days - day
