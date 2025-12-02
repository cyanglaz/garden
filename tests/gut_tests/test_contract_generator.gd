extends GutTest

var generator:CombatGenerator

func before_each():
	generator = CombatGenerator.new()
	generator.generate_bosses(1)

func test_generate_level0() -> void:
	generator.generate_combats(0, CombatGenerator.TOTAL_COMMON_COMBATS_TO_GENERATE_PER_CHAPTER, CombatGenerator.TOTAL_ELITE_COMBATS_TO_GENERATE_PER_CHAPTER, CombatGenerator.TOTAL_BOSS_COMBATS_TO_GENERATE_PER_CHAPTER)

	assert_eq(generator.common_combats.size(), CombatGenerator.TOTAL_COMMON_COMBATS_TO_GENERATE_PER_CHAPTER)
	assert_eq(generator.elite_combats.size(), CombatGenerator.TOTAL_ELITE_COMBATS_TO_GENERATE_PER_CHAPTER)
	assert_eq(generator.boss_combats.size(), CombatGenerator.TOTAL_BOSS_COMBATS_TO_GENERATE_PER_CHAPTER)
	
