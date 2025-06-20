class_name PlayerData
extends CharacterData

@export var actions:Array[ActionData]
@export var powers:Array[PowerData]
@export var max_powers:int = 2
@export var draw_count := 4

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_player_data := other as PlayerData
	actions = other_player_data.actions.duplicate()
	max_powers = other_player_data.max_powers
	draw_count = other_player_data.draw_count
	powers = other_player_data.powers.duplicate()

func get_duplicate() -> PlayerData:
	var dup:PlayerData = PlayerData.new()
	dup.copy(self)
	return dup
