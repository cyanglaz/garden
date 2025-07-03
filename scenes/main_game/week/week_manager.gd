class_name WeekManager
extends RefCounted

const TAX_DUES := [15, 25, 40, 60, 80, 110]

var week:int = 0
var day_manager:DayManager = DayManager.new()
var tax_due:int

func next_week() -> void:
	week += 1
	day_manager.start_new()
	next_day()

func next_day() -> void:
	day_manager.next_day()

func get_day() -> int:
	return day_manager.day

func get_tax_due() -> int:
	return TAX_DUES[week]
