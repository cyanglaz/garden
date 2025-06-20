class_name EnemyBingoBallData
extends BingoBallData

@export var attack_speed:int

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_enemy_bingo_ball_data := other as EnemyBingoBallData
	attack_speed = other_enemy_bingo_ball_data.attack_speed

func get_duplicate() -> EnemyBingoBallData:
	var dup:EnemyBingoBallData = EnemyBingoBallData.new()
	dup.copy(self)
	return dup
