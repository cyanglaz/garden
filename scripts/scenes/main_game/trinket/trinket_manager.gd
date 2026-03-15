class_name TrinketManager
extends RefCounted

signal trinket_pool_updated(trinkets: Array[TrinketData])

var trinket_pool: Array[TrinketData]

func setup(trinkets: Array[TrinketData]) -> void:
	trinket_pool = trinkets

func add_trinket(trinket_data: TrinketData) -> void:
	trinket_pool.append(trinket_data)
	trinket_pool_updated.emit(trinket_pool)
