extends GutTest

# ----- Stubs -----

class FakeTrinketGlobalScript extends TrinketGlobalScript:
	var on_collect_called := false
	func handle_on_collect_hook() -> void:
		on_collect_called = true

class FakeTrinketDataWithScript extends TrinketData:
	var _script: TrinketGlobalScript
	func has_global_script() -> bool:
		return true
	func get_global_script() -> TrinketGlobalScript:
		return _script

class FakeTrinketDataNoScript extends TrinketData:
	func has_global_script() -> bool:
		return false

# ----- collect_trinket: no global script -----

func test_collect_trinket_skips_when_no_global_script() -> void:
	var mgr := TrinketGlobalScriptManager.new()
	var td := FakeTrinketDataNoScript.new()
	mgr.collect_trinket(td)
	assert_eq(mgr.global_scripts.size(), 0)

# ----- collect_trinket: has global script -----

func test_collect_trinket_adds_script_to_array() -> void:
	var mgr := TrinketGlobalScriptManager.new()
	var fake_script := FakeTrinketGlobalScript.new()
	var td := FakeTrinketDataWithScript.new()
	td._script = fake_script
	mgr.collect_trinket(td)
	assert_eq(mgr.global_scripts.size(), 1)
	assert_true(mgr.global_scripts[0] == fake_script)

func test_collect_trinket_calls_on_collect_hook() -> void:
	var mgr := TrinketGlobalScriptManager.new()
	var fake_script := FakeTrinketGlobalScript.new()
	var td := FakeTrinketDataWithScript.new()
	td._script = fake_script
	mgr.collect_trinket(td)
	assert_true(fake_script.on_collect_called)

func test_collect_trinket_multiple_trinkets() -> void:
	var mgr := TrinketGlobalScriptManager.new()
	for i in range(3):
		var fake_script := FakeTrinketGlobalScript.new()
		var td := FakeTrinketDataWithScript.new()
		td._script = fake_script
		mgr.collect_trinket(td)
	assert_eq(mgr.global_scripts.size(), 3)
