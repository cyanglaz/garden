class_name Deck
extends RefCounted

signal draw_pool_updated(draw_pool:Array)
signal discard_pool_updated(discard_pool:Array)
signal pool_updated(pool:Array)

var pool:Array
var draw_pool:Array
var hand:Array
var discard_pool:Array

func _init(initial_items:Array) -> void:
	for item_data:Variant in initial_items:
		pool.append(item_data.get_duplicate())
	draw_pool = pool.duplicate()
	draw_pool.shuffle()

func get_item(index:int) -> Variant:
	return hand[index]

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

func draw(count:int) -> Array:
	var drawn_items:Array = []
	for i in count:
		if draw_pool.is_empty():
			break
		var item:Variant = draw_pool.pop_back()
		hand.append(item)
		drawn_items.append(item)
	draw_pool_updated.emit(draw_pool)
	return drawn_items

func discard(indices:Array) -> void:
	# Removing from largest index to smallest index to avoid index change during removal.
	indices.reverse()
	for index:int in indices:
		var item:Variant = hand[index]
		discard_pool.append(item)
		assert(index >= 0)
		hand.remove_at(index)
	discard_pool_updated.emit(discard_pool)

func insert_item(item:Variant) -> void:
	pool.append(item)
	draw_pool.append(item)
	draw_pool_updated.emit(draw_pool)
	pool_updated.emit(pool)

func remove_item(item:Variant) -> void:
	pool.erase(item)
	draw_pool.erase(item)
	hand.erase(item)
	discard_pool.erase(item)
	draw_pool_updated.emit(draw_pool)
	discard_pool_updated.emit(discard_pool)
	pool_updated.emit(pool)
