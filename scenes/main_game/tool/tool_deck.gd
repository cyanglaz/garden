class_name ToolDeck
extends RefCounted

signal draw_pool_updated(draw_pool:Array[ToolData])
signal discard_pool_updated(discard_pool:Array[ToolData])
signal pool_updated(pool:Array[ToolData])

var pool:Array[ToolData]
var draw_pool:Array[ToolData]
var hand:Array[ToolData]
var discard_pool:Array[ToolData]

func _init(initial_tools:Array[ToolData]) -> void:
	for tool_data:ToolData in initial_tools:
		pool.append(tool_data.get_duplicate())
	draw_pool = pool.duplicate()
	draw_pool.shuffle()

func refresh() -> void:
	draw_pool = pool.duplicate()
	draw_pool.shuffle()
	draw_pool_updated.emit(draw_pool)
	discard_pool.clear()
	discard_pool_updated.emit(discard_pool)
	hand.clear()

func shuffle_draw_pool() -> void:
	assert(draw_pool.size() + discard_pool.size() + hand.size()== pool.size())
	draw_pool.append_array(discard_pool.duplicate())
	draw_pool.shuffle()
	draw_pool_updated.emit(draw_pool)
	discard_pool.clear()
	discard_pool_updated.emit(discard_pool)

func draw(count:int) -> Array[ToolData]:
	var drawn_tools:Array[ToolData] = []
	for i in count:
		if draw_pool.is_empty():
			break
		var tool_data:ToolData = draw_pool.pop_back()
		hand.append(tool_data)
		drawn_tools.append(tool_data)
	draw_pool_updated.emit(draw_pool)
	return drawn_tools

func discard() -> void:
	# Removing from largest index to smallest index to avoid index change during removal.
	for index:int in range(hand.size() - 1, -1, -1):
		var bingo_tool_data:ToolData = hand[index]
		discard_pool.append(bingo_tool_data)
		assert(index >= 0)
		hand.remove_at(index)
	discard_pool_updated.emit(discard_pool)

func insert_tool(tool_data:ToolData) -> void:
	pool.append(tool_data)
	draw_pool.append(tool_data)
	draw_pool_updated.emit(draw_pool)
	pool_updated.emit(pool)

func remove_tool(tool_data:ToolData) -> void:
	pool.erase(tool_data)
	draw_pool.erase(tool_data)
	hand.erase(tool_data)
	discard_pool.erase(tool_data)
	draw_pool_updated.emit(draw_pool)
	discard_pool_updated.emit(discard_pool)
	pool_updated.emit(pool)
