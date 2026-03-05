class_name EventData
extends ThingData

@export var chapters:Array[int]
@export var option_ids:Array[String]

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_event: EventData = other as EventData
	chapters = other_event.chapters.duplicate()
	option_ids = other_event.option_ids.duplicate()
	
func get_duplicate() -> EventData:
	var dup:EventData = EventData.new()
	dup.copy(self)
	return dup
