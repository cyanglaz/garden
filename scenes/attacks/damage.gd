class_name Damage
extends RefCounted

var damage_applied:int
var damage_received:int

func _init(applied:int, received:int) -> void:
	damage_applied = applied
	damage_received = received
