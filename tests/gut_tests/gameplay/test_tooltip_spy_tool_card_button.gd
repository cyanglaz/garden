extends GUIToolCardButton

## Used by test_gui_tool_card_button_tooltip_gate.gd; attached via set_script on instanced scene.
## Only records calls — does not call super (avoids full tooltip / tool_data edge cases in tests).
var tooltip_toggle_calls: Array[bool] = []


func toggle_tooltip(on: bool) -> void:
	tooltip_toggle_calls.append(on)
