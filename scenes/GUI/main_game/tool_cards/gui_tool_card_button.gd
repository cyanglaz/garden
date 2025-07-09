class_name GUIToolCardButton
extends GUIBasicButton

const CARD_HOVER_SOUND := preload("res://resources/sounds/SFX/other/cards/card_hover.wav")
const CARD_SELECT_SOUND := preload("res://resources/sounds/SFX/other/cards/card_select.wav")

@onready var _gui_generic_description: GUIGenericDescription = %GUIGenericDescription
@onready var _card_container: PanelContainer = %CardContainer
@onready var _background: NinePatchRect = %Background
@onready var _cost_label: Label = %CostLabel

var container_offset:float = 0.0: set = _set_container_offset

func update_with_tool_data(tool_data:ToolData) -> void:
	_gui_generic_description.update(tool_data.display_name, tool_data.actions, tool_data.get_display_description())
	_cost_label.text = str(tool_data.energy_cost)

func _set_button_state(bs:GUIBasicButton.ButtonState) -> void:
	super._set_button_state(bs)
	match bs:
		GUIBasicButton.ButtonState.HOVERED:
			_background.region_rect.position.y = 16
		GUIBasicButton.ButtonState.NORMAL:
			_background.region_rect.position.y = 0
		GUIBasicButton.ButtonState.DISABLED:
			_background.region_rect.position.y = 32
		GUIBasicButton.ButtonState.PRESSED, GUIBasicButton.ButtonState.SELECTED:
			_background.region_rect.position.y = 16

func _set_container_offset(offset:float) -> void:
	container_offset = offset
	_card_container.position.y = offset

func _get_hover_sound() -> AudioStream:
	return CARD_HOVER_SOUND

func _get_click_sound() -> AudioStream:
	return CARD_SELECT_SOUND
