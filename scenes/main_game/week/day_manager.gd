class_name DayManager
extends RefCounted

var day:int = 0

func start_new() -> void:
	day = 0

func next_day() -> void:
	day += 1
