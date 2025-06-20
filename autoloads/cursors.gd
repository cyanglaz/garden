extends Node

const DEFAULT_HAND_POINT_CURSOR_IMAGE := preload("res://resources/sprites/GUI/cursor/hand_point.png")
const QUESTION_MARK_CURSOR := preload("res://resources/sprites/GUI/cursor/question_mark_cursor.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor((DEFAULT_HAND_POINT_CURSOR_IMAGE as Texture2D),  Input.CursorShape.CURSOR_POINTING_HAND, Vector2(10, 2))
	Input.set_custom_mouse_cursor((QUESTION_MARK_CURSOR as Texture2D),  Input.CursorShape.CURSOR_HELP)
