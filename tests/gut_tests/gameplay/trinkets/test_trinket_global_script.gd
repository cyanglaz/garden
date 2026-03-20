extends GutTest

# ----- has_on_collect_hook -----

func test_has_on_collect_hook_returns_false() -> void:
	var script := TrinketGlobalScript.new()
	assert_false(script.has_on_collect_hook())

# ----- handle_on_collect_hook -----

func test_handle_on_collect_hook_does_not_error() -> void:
	var script := TrinketGlobalScript.new()
	script.handle_on_collect_hook()
	assert_true(true)
