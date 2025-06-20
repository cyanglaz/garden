class_name DrawBox
extends RefCounted

signal draw_pool_updated(draw_pool:Array[BingoBallData])
signal discard_pool_updated(discard_pool:Array[BingoBallData])
signal pool_updated(pool:Array[BingoBallData])

var pool:Array[BingoBallData]
var draw_pool:Array[BingoBallData]
var hand:Array[BingoBallData]
var discard_pool:Array[BingoBallData]

func _init(initial_balls:Array[BingoBallData]) -> void:
	for ball_data:BingoBallData in initial_balls:
		pool.append(ball_data.get_duplicate())
	draw_pool = pool.duplicate()
	draw_pool.shuffle()

func refresh() -> void:
	draw_pool = pool.duplicate()
	draw_pool.shuffle()
	draw_pool_updated.emit(draw_pool)
	discard_pool.clear()
	discard_pool_updated.emit(discard_pool)
	hand.clear()

func shuffle_box() -> void:
	assert(draw_pool.size() + discard_pool.size() + hand.size()== pool.size())
	draw_pool.append_array(discard_pool.duplicate())
	draw_pool.shuffle()
	draw_pool_updated.emit(draw_pool)
	discard_pool.clear()
	discard_pool_updated.emit(discard_pool)

func draw(count:int) -> Array[BingoBallData]:
	var drawn_balls:Array[BingoBallData] = []
	for i in count:
		if draw_pool.is_empty():
			break
		var ball_data:BingoBallData = draw_pool.pop_back()
		hand.append(ball_data)
		drawn_balls.append(ball_data)
	draw_pool_updated.emit(draw_pool)
	return drawn_balls

func discard() -> void:
	# Removing from largest index to smallest index to avoid index change during removal.
	for index:int in range(hand.size() - 1, -1, -1):
		var bingo_ball_data:BingoBallData = hand[index]
		discard_pool.append(bingo_ball_data)
		assert(index >= 0)
		hand.remove_at(index)
	discard_pool_updated.emit(discard_pool)

func insert_ball(ball_data:BingoBallData) -> void:
	pool.append(ball_data)
	draw_pool.append(ball_data)
	draw_pool_updated.emit(draw_pool)
	pool_updated.emit(pool)

func remove_ball(ball_data:BingoBallData) -> void:
	pool.erase(ball_data)
	draw_pool.erase(ball_data)
	hand.erase(ball_data)
	discard_pool.erase(ball_data)
	draw_pool_updated.emit(draw_pool)
	discard_pool_updated.emit(discard_pool)
	pool_updated.emit(pool)
