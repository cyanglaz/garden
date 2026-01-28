class_name Attack
extends Node2D

const INDICATOR_SCENE := preload("res://scenes/main_game/combat/enemy/attack/indicator/attack_indicator.tscn")

@onready var indicator_container: Node2D = %IndicatorContainer

var attack_data:AttackData

func setup_with_attack_data(ad:AttackData, from_location:Vector2, to_locations:Array[Vector2]) -> void:
	attack_data = ad
	for to_location in to_locations:
		var indicator: AttackIndicator = INDICATOR_SCENE.instantiate()
		indicator_container.add_child(indicator)
		indicator.set_from_to(from_location, to_location)
