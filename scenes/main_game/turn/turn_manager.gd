class_name TurnManager
extends RefCounted

var turn:int = 0

func start_new() -> void:
	turn = 0

func next_turn() -> void:
	turn += 1
