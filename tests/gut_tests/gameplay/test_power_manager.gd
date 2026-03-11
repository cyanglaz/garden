extends GutTest

# Tests for PowerManager — only pure collection methods that do NOT require CombatMain:
#   clear_powers(), remove_single_turn_powers(), get_all_powers().

func _make_power(id: String, single_turn: bool) -> PowerData:
	var pd := PowerData.new()
	pd.id = id
	pd.single_turn = single_turn
	return pd

func _make_manager() -> PowerManager:
	return PowerManager.new()

# ----- clear_powers -----

func test_clear_powers_empties_map() -> void:
	var pm := _make_manager()
	pm.power_map["foo"] = _make_power("foo", false)
	pm.power_map["bar"] = _make_power("bar", true)
	pm.clear_powers()
	assert_eq(pm.power_map.size(), 0)

func test_clear_powers_emits_power_updated() -> void:
	var pm := _make_manager()
	pm.power_map["foo"] = _make_power("foo", false)
	watch_signals(pm)
	pm.clear_powers()
	assert_signal_emitted(pm, "power_updated")

func test_clear_powers_on_empty_map_no_crash() -> void:
	var pm := _make_manager()
	watch_signals(pm)
	pm.clear_powers()
	assert_eq(pm.power_map.size(), 0)
	assert_signal_emitted(pm, "power_updated")

# ----- remove_single_turn_powers -----

func test_remove_single_turn_removes_temp_powers() -> void:
	var pm := _make_manager()
	pm.power_map["temp"] = _make_power("temp", true)
	pm.remove_single_turn_powers()
	assert_false(pm.power_map.has("temp"))

func test_remove_single_turn_keeps_permanent_powers() -> void:
	var pm := _make_manager()
	pm.power_map["perm"] = _make_power("perm", false)
	pm.remove_single_turn_powers()
	assert_true(pm.power_map.has("perm"))

func test_remove_single_turn_mixed() -> void:
	var pm := _make_manager()
	pm.power_map["perm"] = _make_power("perm", false)
	pm.power_map["temp"] = _make_power("temp", true)
	pm.remove_single_turn_powers()
	assert_true(pm.power_map.has("perm"))
	assert_false(pm.power_map.has("temp"))

func test_remove_single_turn_emits_power_updated() -> void:
	var pm := _make_manager()
	pm.power_map["temp"] = _make_power("temp", true)
	watch_signals(pm)
	pm.remove_single_turn_powers()
	assert_signal_emitted(pm, "power_updated")

func test_remove_single_turn_on_empty_map_no_crash() -> void:
	var pm := _make_manager()
	watch_signals(pm)
	pm.remove_single_turn_powers()
	assert_eq(pm.power_map.size(), 0)
	assert_signal_emitted(pm, "power_updated")

# ----- get_all_powers -----

func test_get_all_powers_returns_values() -> void:
	var pm := _make_manager()
	var p1 := _make_power("a", false)
	var p2 := _make_power("b", true)
	pm.power_map["a"] = p1
	pm.power_map["b"] = p2
	var result := pm.get_all_powers()
	assert_eq(result.size(), 2)
	assert_true(p1 in result)
	assert_true(p2 in result)

func test_get_all_powers_empty() -> void:
	var pm := _make_manager()
	assert_eq(pm.get_all_powers().size(), 0)
