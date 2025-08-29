class_name Deck
extends RefCounted

signal draw_pool_updated(draw_pool:Array)
signal discard_pool_updated(discard_pool:Array)
signal pool_updated(pool:Array)

var pool:Array
var draw_pool:Array
var hand:Array
var discard_pool:Array
var in_use_item:Variant = null

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
	draw_pool.append_array(discard_pool.duplicate())
	draw_pool.shuffle()
	draw_pool_updated.emit(draw_pool)
	discard_pool.clear()
	discard_pool_updated.emit(discard_pool)
	#if pool[0] is PlantData:
		#print("draw pool: ", draw_pool.size())
		#for item in draw_pool:
			#print(item.id)
		#print("discard pool: ", discard_pool.size())
		#for item in discard_pool:
			#print(item.id)
		#print("hand: ", hand.size())
		#for item in hand:
			#print(item.id)

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
		if hand.has(item):
			hand.erase(item)
		else:
			assert(false, "discarding item not in hand" + str(item))
	discard_pool_updated.emit(discard_pool)

func use(item:Variant) -> void:
	in_use_item = item

func add_item(item:Variant) -> void:
	pool.append(item)
	pool_updated.emit(pool)

func add_temp_item_to_draw_pile(item:Variant, random_place:bool = true) -> void:
	pool.append(item)
	if random_place && draw_pool.size() > 0:
		draw_pool.insert(randi() % draw_pool.size(), item)
	else:
		draw_pool.insert(0, item)
	draw_pool_updated.emit(draw_pool)

func remove_item(item:Variant) -> void:
	pool.erase(item)
	draw_pool.erase(item)
	hand.erase(item)
	discard_pool.erase(item)
	draw_pool_updated.emit(draw_pool)
	discard_pool_updated.emit(discard_pool)
	pool_updated.emit(pool)
