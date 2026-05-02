extends GutTest


func test_setting_max_value_does_not_increase_current_value() -> void:
	var point := ResourcePoint.new()
	point.setup(2, 3)

	point.max_value = 5

	assert_eq(point.value, 2)
	assert_eq(point.max_value, 5)


func test_setting_max_value_clamps_existing_value_when_cap_is_lowered() -> void:
	var point := ResourcePoint.new()
	point.setup(5, 5)

	point.max_value = 3

	assert_eq(point.value, 3)
	assert_eq(point.max_value, 3)
