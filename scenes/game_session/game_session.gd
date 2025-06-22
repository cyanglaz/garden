class_name GameSession
extends Node2D

@onready var field_container: FieldContainer = %FieldContainer

func _ready() -> void:
	field_container.update_with_number_of_fields(3)
