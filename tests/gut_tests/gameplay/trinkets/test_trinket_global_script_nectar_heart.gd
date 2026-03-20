extends GutTest

# ----- Helpers -----

func _make_script() -> TrinketGlobalScriptNectarHeart:
	var s := TrinketGlobalScriptNectarHeart.new()
	var td := TrinketData.new()
	td.data[&"max_hp"] = "2"
	s.trinket_data = td
	return s

# ----- has_on_collect_hook -----

func test_has_on_collect_hook_returns_true() -> void:
	assert_true(_make_script().has_on_collect_hook())
