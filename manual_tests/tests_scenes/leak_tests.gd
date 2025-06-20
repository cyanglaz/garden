extends Node2D

const BALL_DATA := preload("res://data/balls/starting/bingo_ball_sword.tres")

func _ready() -> void:
	await _run()
		
func _run() -> void:
	await get_tree().create_timer(0.05).timeout
	var test_ref := RefCounted.new()
	#var bingo_space_data = BingoSpaceData.new()
	#bingo_space_data.ball_data = BALL_DATA.get_duplicate()
	await get_tree().create_timer(0.05).timeout
	test_ref = null
	#bingo_space_data.ball_data = null
	await _run()
