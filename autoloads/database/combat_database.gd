class_name CombatDatabase
extends Database

const DIR = "res://data/combats"

func roll_combats_for_chapter(chapter:int, type: CombatData.CombatType) -> Array:
	var all_combats_for_chapter:Array = _get_all_resources(_datas, str("chapter", chapter+1)).values()
	var combats_for_type:Array = all_combats_for_chapter.filter(func(combat:CombatData) -> bool: return combat.combat_type == type)
	return combats_for_type.duplicate()

func _get_data_dir() -> String:
	return DIR
