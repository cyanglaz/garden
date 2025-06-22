class_name Plant
extends Node2D

@onready var plant_sprite: AnimatedSprite2D = %PlantSprite
@onready var fsm: PlantStateMachine = %PlantStateMachine

func _ready() -> void:
	fsm.start()
