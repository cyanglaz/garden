class_name WeekManager
extends RefCounted

const BASE_POINTS := 15
const POINTS_INCREASE_PER_WEEK := 5
const WEEKS_PER_BOSS := 4

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
	return BASE_POINTS + POINTS_INCREASE_PER_WEEK * week
