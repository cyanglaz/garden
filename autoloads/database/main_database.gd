extends Node

#var item_database:ItemDatabase = ItemDatabase.new()
var ball_database:BallDataBase = BallDataBase.new()
var player_ball_database:PlayerBallDataBase = PlayerBallDataBase.new()
var status_effect_database:StatusEffectDataBase = StatusEffectDataBase.new()
var enemy_database:EnemyDataBase = EnemyDataBase.new()
var space_effect_database:SpaceEffectDatabase = SpaceEffectDatabase.new()
var power_database:PowerDatabase = PowerDatabase.new()

func _ready() -> void:
	#add_child(item_database)
	add_child(ball_database)
	add_child(status_effect_database)
	add_child(enemy_database)
	add_child(space_effect_database)
	add_child(player_ball_database)
	add_child(power_database)
