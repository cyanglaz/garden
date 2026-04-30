extends GutTest


func test_default_has_show_card_tooltip_true() -> void:
	var defaults: SettingData = load("res://data/settings/default_settings.tres") as SettingData
	assert_not_null(defaults)
	assert_true(defaults.show_card_tooltip)


func test_new_instance_default_true() -> void:
	var data := SettingData.new()
	assert_true(data.show_card_tooltip)


func test_default_has_show_detail_tooltip_true() -> void:
	var defaults: SettingData = load("res://data/settings/default_settings.tres") as SettingData
	assert_not_null(defaults)
	assert_true(defaults.show_detail_tooltip)


func test_new_instance_show_detail_tooltip_default_true() -> void:
	var data := SettingData.new()
	assert_true(data.show_detail_tooltip)
