class_name SpaceEffectData
extends ThingData

@export var show_stack := false

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_space_effect_data := other as SpaceEffectData
	show_stack = other_space_effect_data.show_stack

func get_duplicate() -> SpaceEffectData:
	var dup:SpaceEffectData = SpaceEffectData.new()
	dup.copy(self)
	return dup
