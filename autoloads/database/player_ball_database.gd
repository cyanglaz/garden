class_name PlayerBallDataBase
extends Database

const DIR = "res://data/balls/player"

func roll_balls(number_of_balls:int, level:int) -> Array[BingoBallData]:
	var all_balls := get_all_datas().duplicate()
	# Weighted roll.
	var balls:Array[BingoBallData] = []
	for i in number_of_balls:
		var weights := all_balls.map(func(data:BingoBallData):return data.get_weight(level))
		if all_balls.size() == 0:
			break
		var index := Util.weighted_roll(all_balls, weights)
		var ball_data:BingoBallData = all_balls[index]
		all_balls.erase(ball_data)
		balls.append(ball_data.get_duplicate())
	#balls.append(load("res://data/balls/player/bingo_ball_quick_draw.tres"))
	#balls.append(load("res://data/balls/player/bingo_ball_quick_draw.tres"))
	#balls.append(load("res://data/balls/player/bingo_ball_quick_draw.tres"))
	#balls.append(load("res://data/balls/player/bingo_ball_quick_draw.tres"))
	return balls

func _get_data_dir() -> String:
	return DIR
