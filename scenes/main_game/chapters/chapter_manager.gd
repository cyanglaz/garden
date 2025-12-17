class_name ChapterManager
extends RefCounted

var current_chapter:int = -1

var common_combats:Array = []
var elite_combats:Array = []
var boss_combats:Array = []

func next_chapter() -> void:
	current_chapter += 1
	common_combats = MainDatabase.combat_database.roll_combats_for_chapter(current_chapter, CombatData.CombatType.COMMON)
	elite_combats = MainDatabase.combat_database.roll_combats_for_chapter(current_chapter, CombatData.CombatType.ELITE)
	boss_combats = MainDatabase.combat_database.roll_combats_for_chapter(current_chapter, CombatData.CombatType.BOSS)
	common_combats.shuffle()
	elite_combats.shuffle()
	boss_combats.shuffle()

func fetch_common_combat_data() -> CombatData:
	if common_combats.is_empty():
		common_combats = MainDatabase.combat_database.roll_combats_for_chapter(current_chapter, CombatData.CombatType.COMMON)
		common_combats.shuffle()
	return common_combats.pop_back()

func fetch_elite_combat_data() -> CombatData:
	if elite_combats.is_empty():
		elite_combats = MainDatabase.combat_database.roll_combats_for_chapter(current_chapter, CombatData.CombatType.ELITE)
		elite_combats.shuffle()
	return elite_combats.pop_back()

func fetch_boss_combat_data() -> CombatData:
	assert(boss_combats.size() > 0, "Boss combat must be available")
	return boss_combats.pop_back()
