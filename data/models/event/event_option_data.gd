class_name EventOptionData
extends ThingData

@export var positive_description:String
@export var negative_description:String

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_event_option: EventOptionData = other as EventOptionData
	
func get_duplicate() -> EventOptionData:
	var dup:EventOptionData = EventOptionData.new()
	dup.copy(self)
	return dup
