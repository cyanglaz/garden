class_name TrinketGlobalScriptManager
extends RefCounted

var global_scripts: Array[TrinketGlobalScript] = []
	
func collect_trinket(trinket_data: TrinketData) -> void:
	if !trinket_data.has_global_script():
		return
	var script := trinket_data.get_global_script()
	global_scripts.append(script)
	script.handle_on_collect_hook()
