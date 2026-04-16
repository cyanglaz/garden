extends GutTest

const CHECKBOX_SCENE := preload("res://scenes/GUI/controls/buttons/gui_checkbox_button.tscn")


func _add_checkbox() -> GUICheckBoxButton:
	var checkbox: GUICheckBoxButton = CHECKBOX_SCENE.instantiate()
	add_child_autofree(checkbox)
	return checkbox


func _atlas_pos(checkbox: GUICheckBoxButton) -> Vector2:
	var tex := checkbox.texture_rect.texture as AtlasTexture
	return tex.region.position


func test_initial_state_is_off() -> void:
	var checkbox := _add_checkbox()
	assert_false(checkbox.on)


func test_pressed_emits_checked_true_then_false() -> void:
	var checkbox := _add_checkbox()
	watch_signals(checkbox)
	checkbox.pressed.emit()
	assert_signal_emitted_with_parameters(checkbox, "checked", [true])
	assert_true(checkbox.on)
	checkbox.pressed.emit()
	assert_signal_emit_count(checkbox, "checked", 2)
	assert_signal_emitted_with_parameters(checkbox, "checked", [false])
	assert_false(checkbox.on)


func test_texture_region_updates_on_toggle() -> void:
	var checkbox := _add_checkbox()
	assert_eq(_atlas_pos(checkbox), Vector2(0, 0))
	checkbox.pressed.emit()
	assert_eq(_atlas_pos(checkbox), Vector2(0, GUICheckBoxButton.SIZE.y))
	checkbox.pressed.emit()
	assert_eq(_atlas_pos(checkbox), Vector2(0, 0))


func test_state_changes_update_region_x() -> void:
	var checkbox := _add_checkbox()
	checkbox.on = false
	checkbox.button_state = GUIBasicButton.ButtonState.NORMAL
	assert_eq(_atlas_pos(checkbox), Vector2(0, 0))
	checkbox.button_state = GUIBasicButton.ButtonState.PRESSED
	assert_eq(_atlas_pos(checkbox), Vector2(GUICheckBoxButton.SIZE.x, 0))
	checkbox.button_state = GUIBasicButton.ButtonState.HOVERED
	assert_eq(_atlas_pos(checkbox), Vector2(GUICheckBoxButton.SIZE.x * 2, 0))


func test_disabled_uses_bottom_row() -> void:
	var checkbox := _add_checkbox()
	checkbox.on = false
	checkbox.button_state = GUIBasicButton.ButtonState.DISABLED
	assert_eq(_atlas_pos(checkbox), Vector2(0, GUICheckBoxButton.SIZE.y * 2))
