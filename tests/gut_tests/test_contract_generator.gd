extends GutTest

var generator:ContractGenerator

func before_each():
	generator = ContractGenerator.new()

func test_generate_level0() -> void:
	generator.generate_contracts(0)

	assert_eq(generator.common_contracts.size(), ContractGenerator.TOTAL_COMMON_CONTRACTS_TO_GENERATE_PER_CHAPTER)
	assert_eq(generator.elite_contracts.size(), ContractGenerator.TOTAL_ELITE_CONTRACTS_TO_GENERATE_PER_CHAPTER)
	assert_not_null(generator.boss_contract)
	
