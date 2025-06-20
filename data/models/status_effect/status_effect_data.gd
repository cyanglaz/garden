class_name StatusEffectData
extends ThingData

@export var single_turn:bool = false

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_status_effect_data := other as StatusEffectData
	single_turn = other_status_effect_data.single_turn

func get_duplicate() -> StatusEffectData:
	var dup:StatusEffectData = StatusEffectData.new()
	dup.copy(self)
	return dup

func get_formatted_description() -> String:
	return description.format(data)
