class_name DayManager
extends RefCounted

var day:int = -1

func start_new() -> void:
	day = -1

func next_day() -> void:
	day += 1
