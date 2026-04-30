extends GutTest

var _saved_show_detail_tooltip: bool


func before_each() -> void:
	_saved_show_detail_tooltip = PlayerSettings.setting_data.show_detail_tooltip


func after_each() -> void:
	PlayerSettings.update_show_detail_tooltip(_saved_show_detail_tooltip)


func test_update_show_detail_tooltip_sets_value() -> void:
	PlayerSettings.update_show_detail_tooltip(false)
	assert_false(PlayerSettings.setting_data.show_detail_tooltip)
	PlayerSettings.update_show_detail_tooltip(true)
	assert_true(PlayerSettings.setting_data.show_detail_tooltip)
