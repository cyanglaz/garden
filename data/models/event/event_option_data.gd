class_name EventOptionData
extends ThingData

@export var positive_description:String
@export var negative_description:String
@export var script_id:String

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_event_option: EventOptionData = other as EventOptionData
	positive_description = other_event_option.positive_description
	negative_description = other_event_option.negative_description
	
func get_duplicate() -> EventOptionData:
	var dup:EventOptionData = EventOptionData.new()
	dup.copy(self)
	return dup

func _get_localization_prefix() -> String:
	return "EVENT_OPTION_"

func get_display_positive_description() -> String:
	var raw := positive_description
	if !id.is_empty():
		var key := "EVENT_OPTION_" + id.to_upper() + "_POSITIVE_DESCRIPTION"
		var localized := Util.get_localized_string(key)
		if localized != key:
			raw = localized
	return raw

func get_display_negative_description() -> String:
	var raw := negative_description
	if !id.is_empty():
		var key := "EVENT_OPTION_" + id.to_upper() + "_NEGATIVE_DESCRIPTION"
		var localized := Util.get_localized_string(key)
		if localized != key:
			raw = localized
	return raw
