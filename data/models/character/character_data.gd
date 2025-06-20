class_name CharacterData
extends ThingData

@export var max_hp:int
@export var initial_balls:Array[BingoBallData]

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_character_data := other as CharacterData
	max_hp = other_character_data.max_hp
	initial_balls = other_character_data.initial_balls.duplicate()

func get_duplicate() -> CharacterData:
	var dup:CharacterData = CharacterData.new()
	dup.copy(self)
	return dup
