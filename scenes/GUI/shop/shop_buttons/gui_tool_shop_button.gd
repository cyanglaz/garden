class_name GUIToolShopButton
extends GUIShopButton

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

var _card_tooltip_id:String = ""
var _weak_tool_data:WeakRef = weakref(null)

func update_with_tool_data(tool_data:ToolData) -> void:
	_weak_tool_data = weakref(tool_data)
	gui_tool_card_button.update_with_tool_data(tool_data)
	gui_tool_card_button.mouse_disabled = true
	cost = tool_data.cost

func _set_highlighted(val:bool) -> void:
	super._set_highlighted(val)
	if val:
		gui_tool_card_button.card_state = GUIToolCardButton.CardState.HIGHLIGHTED
	else:
		gui_tool_card_button.card_state = GUIToolCardButton.CardState.NORMAL

func _get_hover_sound() -> AudioStream:
	return gui_tool_card_button._get_hover_sound()

func _get_click_sound() -> AudioStream:
	return gui_tool_card_button._get_click_sound()

func _set_sufficient_gold(val:bool) -> void:
	super._set_sufficient_gold(val)
	if val:
		gui_tool_card_button.resource_sufficient = true
	else:
		gui_tool_card_button.resource_sufficient = false

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	highlighted = true
	gold_icon.has_outline = true
	_card_tooltip_id = Util.get_uuid()
	gui_tool_card_button.card_state = GUIToolCardButton.CardState.HIGHLIGHTED
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.TOOL_CARD, _weak_tool_data.get_ref(), _card_tooltip_id, gui_tool_card_button, false, GUITooltip.TooltipPosition.RIGHT, false)

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	highlighted = false
	gold_icon.has_outline = false
	gui_tool_card_button.card_state = GUIToolCardButton.CardState.NORMAL
	Events.request_hide_tooltip.emit(_card_tooltip_id)
	_card_tooltip_id = ""
