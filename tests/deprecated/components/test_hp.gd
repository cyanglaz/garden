extends GutTest

const MAX_HP := 100

var hp:HP

func before_each():
	hp = HP.new()
	hp.setup(MAX_HP, MAX_HP)
	hp.show_damage_label = false

func test_max_value_updated():
	watch_signals(hp)
	hp.max_value = MAX_HP + 10
	assert_signal_emitted(hp, "max_value_update")
	
func test_value_updated():
	watch_signals(hp)
	hp.value = MAX_HP - 10
	assert_signal_emitted(hp, "value_update")
	
func test_value_cannot_be_grader_than_max_value():
	hp.value = hp.max_value + 1
	assert_eq(hp.value, hp.max_value)
	
func test_value_spend():
	watch_signals(hp)
	hp.apply_damage(1)
	assert_signal_emitted(hp, "value_update")
	assert_eq(hp.value, MAX_HP - 1)
	
func test_value_restore():
	watch_signals(hp)
	hp.apply_damage(1)
	hp.restore(1)
	assert_signal_emitted(hp, "value_update")
	assert_eq(hp.value, hp.max_value)

func test_value_empty():
	watch_signals(hp)
	assert_false(hp.is_empty)
	hp.apply_damage(MAX_HP)
	assert_eq(hp.value, 0)
	assert_true(hp.is_empty)
	assert_signal_emitted(hp, "empty")

func test_value_reset():
	hp.apply_damage(MAX_HP)
	hp.reset()
	assert_eq(hp.value, hp.max_value)
	assert_eq(hp.max_value, MAX_HP)

func test_shield():
	hp.shield = 2
	
	hp.apply_damage(15)
	assert_eq(hp.value, MAX_HP - 13)
	
