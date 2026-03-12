class_name PlayerData
extends CharacterData

@export var initial_tools:Array[ToolData]
@export var initial_trinkets:Array[TrinketData]
@export var starting_movements:int = 3
@export var hp:int = 10

func _get_localization_prefix() -> String:
	return "PLAYER_"
