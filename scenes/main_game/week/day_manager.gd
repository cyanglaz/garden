class_name DayManager
extends RefCounted

var day:int = 0
var last_day:int = 0

func start_new(level_data:LevelData) -> void:
	last_day = level_data.number_of_days - 1
	day = -1

func next_day() -> void:
	day += 1

func get_day_left() -> int:
	return last_day - day
