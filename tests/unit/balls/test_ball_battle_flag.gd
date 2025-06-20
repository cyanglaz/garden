extends GutTest

const BALL_DATA:BingoBallData = preload("res://data/balls/player/bingo_ball_battle_flag.tres")

func test_damage() -> void:
	assert_eq(BALL_DATA.damage, 0)

func test_type() -> void:
	assert_eq(BALL_DATA.type, BingoBallData.Type.SKILL)

func test_rarity() -> void:
	assert_eq(BALL_DATA.rarity, BingoBallData.Rarity.UNCOMMON)

func test_placement_rules() -> void:
	assert_eq(BALL_DATA.placement_rule, BingoBallData.PlacementRule.ALL)

func test_placement_event() -> void:
	var ball_data := BALL_DATA.get_duplicate()
	assert_true(ball_data.ball_script._has_placement_events())

func test_add_strength_to_spaces_on_the_same_column() -> void:

	var script = partial_double(BingoBallScriptBattleFlag).new(BALL_DATA)

	var fixture_spaces := []
	for i in 4:
		var space := BingoSpaceData.new()
		space.index = i
		fixture_spaces.append(space)

	stub(script, "_get_spaces_on_the_same_column").to_return(fixture_spaces)

	# Add ball to add strength to spaces
	script._handle_placement_events()
	for space in fixture_spaces:
		assert_eq(space.space_effect_manager.get_space_effect("strength").stack, 1)
	
	# Remove ball to remove strength from spaces
	script._handle_removed_from_board()
	for space in fixture_spaces:
		assert_null(space.space_effect_manager.get_space_effect("strength"))
