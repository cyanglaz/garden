class_name EnemyData
extends CharacterData

enum Type {
	NORMAL,
	BOSS
}

@export var type:Type
@export var appearance_level:int

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_character_data := other as EnemyData
	type = other_character_data.type
	appearance_level = other_character_data.appearance_level

func get_duplicate() -> EnemyData:
	var dup:EnemyData = EnemyData.new()
	dup.copy(self)
	return dup
