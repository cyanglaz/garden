extends GUIToolCardButton

## Used by test_gui_tool_card_button_hover_signal.gd. Stubs the hover probe
## so _refresh_card_hover_state() transition logic can be tested deterministically.
var stub_mouse_over: bool = false


func _is_mouse_over_card() -> bool:
	return stub_mouse_over
