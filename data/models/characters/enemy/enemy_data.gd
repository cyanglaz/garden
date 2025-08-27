class_name EnemyData
extends CharacterData

enum Type {
	MINION,
	BOSS
}

@export var type:Type
@export var appearing_chapters:Array[int]
