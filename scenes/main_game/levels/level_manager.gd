class_name LevelManager
extends RefCounted

const LEVEL_PER_CHAPTER := 4

var levels:Array[LevelData]

func generate_with_chapter(chapter:int) -> void:
	levels.clear()
	levels = MainDatabase.level_database.roll_levels(LEVEL_PER_CHAPTER, chapter)
