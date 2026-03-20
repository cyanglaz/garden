class_name TrinketManager
extends RefCounted

signal trinket_pool_updated(trinkets: Array[TrinketData])

var trinket_pool: Array[TrinketData]
var trinket_global_script_manager: TrinketGlobalScriptManager = TrinketGlobalScriptManager.new()

func setup(trinkets: Array[TrinketData]) -> void:
	for trinket in trinkets:
		add_trinket(trinket)

func add_trinket(trinket_data: TrinketData) -> void:
	trinket_pool.append(trinket_data)
	trinket_pool_updated.emit(trinket_pool)
	trinket_global_script_manager.collect_trinket(trinket_data)
