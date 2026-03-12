extends GutTest

func _make_player_data() -> PlayerData:
	return PlayerData.new()

func test_initial_trinkets_defaults_to_empty():
	var pd := _make_player_data()
	assert_eq(pd.initial_trinkets.size(), 0)

func test_initial_trinkets_can_be_set():
	var pd := _make_player_data()
	var td := TrinketData.new()
	pd.initial_trinkets = [td]
	assert_eq(pd.initial_trinkets.size(), 1)

func test_initial_tools_defaults_to_empty():
	var pd := _make_player_data()
	assert_eq(pd.initial_tools.size(), 0)
