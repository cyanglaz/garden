class_name BingoBallTestUtil
extends RefCounted

const PLAYER_DATA:CharacterData = preload("res://tests/fixtures/ut_player_data.tres")
const ENEMY_DATA:CharacterData = preload("res://tests/fixtures/ut_enemy_data.tres")

static func create_bingo_result(ball_datas:Array, bingo_type:BingoResult.BingoType, space_indexes:Array[int] = [0, 1, 2, 3, 4]) -> BingoResult:
	var spaces_datas:Array[BingoSpaceData]= []
	var i := 0
	for ball_data:BingoBallData in ball_datas:
		var space_data := BingoSpaceData.new()
		space_data.ball_data = ball_data
		space_data.index = space_indexes[i]
		spaces_datas.append(space_data)
		i += 1
	return BingoResult.new(spaces_datas, bingo_type)
