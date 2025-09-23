class_name ChapterManager
extends RefCounted

var current_chapter:int = -1

func next_chapter() -> void:
	current_chapter += 1
