class_name EventDatabase
extends Database

const DIR = "res://data/events/events"

func get_events_by_chapter(chapter:int) -> Array:
	var all_events := _get_all_resources(_datas, "").values()
	var events_for_chapter:Array = all_events.filter(func(event:EventData) -> bool: return event.chapters.has(chapter))
	events_for_chapter.shuffle()
	return events_for_chapter.duplicate()

func _get_data_dir() -> String:
	return DIR
