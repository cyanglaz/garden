class_name GUILibraryItemWrapperButton
extends GUIBasicButton

@onready var margin_container: MarginContainer = %MarginContainer

func add_item(item:Control) -> void:
	margin_container.add_child(item)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	var child_button := _get_child_button()
	if child_button:
		child_button.button_state = val
	if child_button is GUIToolCardButton:
		match val:
			ButtonState.NORMAL, ButtonState.PRESSED, ButtonState.DISABLED:
				child_button.card_state = GUIToolCardButton.CardState.NORMAL
			ButtonState.SELECTED:
				child_button.card_state = GUIToolCardButton.CardState.SELECTED
			ButtonState.HOVERED:
				child_button.card_state = GUIToolCardButton.CardState.HIGHLIGHTED

func _get_hover_sound() -> AudioStream:
	var child_button := _get_child_button()
	if child_button:
		return child_button._get_hover_sound()
	return super._get_hover_sound()

func _get_click_sound() -> AudioStream:
	var child_button := _get_child_button()
	if child_button:
		return child_button._get_click_sound()
	return super._get_click_sound()

func _get_child_button() -> GUIBasicButton:
	if !margin_container:
		return null
	if margin_container.get_child_count() == 0:
		return null
	return margin_container.get_child(0) as GUIBasicButton
