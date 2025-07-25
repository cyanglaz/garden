class_name WeekManager
extends RefCounted

const TAX_DUES := [15, 25, 40, 60, 80, 110]

var week:int = -1
var day_manager:DayManager = DayManager.new()

func next_week() -> void:
	week += 1
	day_manager.start_new()

func next_day() -> void:
	day_manager.next_day()

func get_day() -> int:
	return day_manager.day

func get_tax_due() -> int:
	return TAX_DUES[week]
