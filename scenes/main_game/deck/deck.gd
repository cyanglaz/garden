class_name Deck
extends RefCounted

signal draw_pool_updated(draw_pool:Array)
signal discard_pool_updated(discard_pool:Array)
signal exhaust_pool_updated(exhaust_pool:Array)
signal pool_updated(pool:Array)

var pool:Array
var draw_pool:Array
var hand:Array
var discard_pool:Array
var exhaust_pool:Array
var in_use_item:Variant = null
var temp_items:Array = []

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
	exhaust_pool.clear()
	exhaust_pool_updated.emit(exhaust_pool)
	hand.clear()

func cleanup_temp_items() -> void:
	for item in temp_items:
		pool.erase(item)
		draw_pool.erase(item)
		temp_items.erase(item)
		discard_pool.erase(item)
		hand.erase(item)
	pool_updated.emit(pool)
	draw_pool_updated.emit(draw_pool)
	discard_pool_updated.emit(discard_pool)
	temp_items.clear()

func shuffle_draw_pool() -> void:
	assert(draw_pool.size() + discard_pool.size() + hand.size() + exhaust_pool.size() + (1 if in_use_item else 0) == pool.size())
	draw_pool.append_array(discard_pool.duplicate())
	draw_pool.shuffle()
	draw_pool_updated.emit(draw_pool)
	discard_pool.clear()
	discard_pool_updated.emit(discard_pool)

func draw(count:int, indices:Array = []) -> Array:
	indices = indices.duplicate()
	indices.sort()
	var drawn_items:Array = []
	for i in count:
		if draw_pool.is_empty():
			break
		var item:Variant = draw_pool.pop_front()
		if indices.is_empty():
			hand.append(item)
		else:
			hand.insert(indices.pop_front(), item)
		drawn_items.append(item)
	draw_pool_updated.emit(draw_pool)
	return drawn_items

func discard(items:Array) -> void:
	# Removing from largest index to smallest index to avoid index change during removal.
	for item:Variant in items:
		discard_pool.append(item)
		if item == in_use_item:
			in_use_item = null
		elif hand.has(item):
			hand.erase(item)
		else:
			assert(false, "discarding item not in hand" + str(item))
	discard_pool_updated.emit(discard_pool)

func use(item:Variant) -> void:
	hand.erase(item)
	in_use_item = item

func exhaust(items:Array) -> void:
	for item:Variant in items:
		if item == in_use_item:
			in_use_item = null
		elif hand.has(item):
			hand.erase(item)
		elif discard_pool.has(item):
			discard_pool.erase(item)
			discard_pool_updated.emit(discard_pool)
		elif draw_pool.has(item):
			draw_pool.erase(item)
			draw_pool_updated.emit(draw_pool)
		else:
			assert(false, "exhausting item at wrong place" + str(item))
	exhaust_pool.append_array(items)
	exhaust_pool_updated.emit(exhaust_pool)

func add_item(item:Variant) -> void:
	pool.append(item)
	pool_updated.emit(pool)

func add_temp_items_to_draw_pile(items:Array, random_place:bool = true) -> void:
	pool.append_array(items)
	for item in items:
		if random_place && draw_pool.size() > 0:
			draw_pool.insert(randi() % draw_pool.size(), item)
		else:
			draw_pool.insert(0, item)
	draw_pool_updated.emit(draw_pool)
	pool_updated.emit(pool)
	temp_items.append_array(items)

func remove_item(item:Variant) -> void:
	pool.erase(item)
	draw_pool.erase(item)
	hand.erase(item)
	discard_pool.erase(item)
	draw_pool_updated.emit(draw_pool)
	discard_pool_updated.emit(discard_pool)
	pool_updated.emit(pool)
	if item == in_use_item:
		in_use_item = null

func filter_items(filter_func:Callable) -> void:
	pool = pool.filter(filter_func)
	pool_updated.emit(pool)
	draw_pool = draw_pool.filter(filter_func)
	draw_pool_updated.emit(draw_pool)
	discard_pool = discard_pool.filter(filter_func)
	discard_pool_updated.emit(discard_pool)
	exhaust_pool = exhaust_pool.filter(filter_func)
	exhaust_pool_updated.emit(exhaust_pool)
	hand = hand.filter(filter_func)
