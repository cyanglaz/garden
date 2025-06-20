extends GutTest

var resource_point:ResourcePoint

func before_each():
	resource_point = ResourcePoint.new()
	resource_point.setup(2, 2)

func test_max_value_updated():
	watch_signals(resource_point)
	resource_point.max_value = 3
	assert_signal_emitted(resource_point, "max_value_update")
	
func test_value_updated():
	watch_signals(resource_point)
	resource_point.value = 1
	assert_signal_emitted(resource_point, "value_update")
	
func test_value_cannot_be_grader_than_max_value():
	resource_point.value = resource_point.max_value + 1
	assert_eq(resource_point.value, resource_point.max_value)
	
func test_value_spend():
	watch_signals(resource_point)
	resource_point.spend(1)
	assert_signal_emitted(resource_point, "value_update")
	assert_eq(resource_point.value, 1)
	
func test_value_restore():
	watch_signals(resource_point)
	resource_point.spend(1)
	resource_point.restore(1)
	assert_signal_emitted(resource_point, "value_update")
	assert_eq(resource_point.value, resource_point.max_value)

func test_value_empty():
	watch_signals(resource_point)
	assert_false(resource_point.is_empty)
	resource_point.spend(2)
	assert_eq(resource_point.value, 0)
	assert_true(resource_point.is_empty)
	assert_signal_emitted(resource_point, "empty")

func test_value_reset():
	resource_point.spend(2)
	resource_point.reset()
	assert_eq(resource_point.value, resource_point.max_value)

func test_over_spend():
	watch_signals(resource_point)
	assert_false(resource_point.is_empty)
	resource_point.spend(3)
	assert_eq(resource_point.value, 0)
	assert_true(resource_point.is_empty)
	assert_signal_emitted(resource_point, "empty")

