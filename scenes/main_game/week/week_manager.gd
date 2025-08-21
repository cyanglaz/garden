class_name WeekManager
extends RefCounted

const POINTS_DUES := [5, 25, 40, 60, 80, 110]

var week:int = -1
var day_manager:DayManager = DayManager.new()

func next_week() -> void:
	week += 1
	day_manager.start_new()

func next_day() -> void:
	day_manager.next_day()

func get_day() -> int:
	return day_manager.day

func get_day_left() -> int:
	return 6 - day_manager.day

func get_points_due() -> int:
	return POINTS_DUES[week]
