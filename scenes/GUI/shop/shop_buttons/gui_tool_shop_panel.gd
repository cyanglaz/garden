class_name GUIToolShopPanel
extends GUIShopPanel

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

var _weak_tool_data:WeakRef = weakref(null)

func update_with_tool_data(tool_data:ToolData) -> void:
	_weak_tool_data = weakref(tool_data)
	gui_tool_card_button.update_with_tool_data(tool_data, null)
	gui_tool_card_button.mouse_disabled = true
	cost = tool_data.cost

func _get_hover_sound() -> AudioStream:
	return gui_tool_card_button._get_hover_sound()

func _get_click_sound() -> AudioStream:
	return gui_tool_card_button._get_click_sound()

func update_for_gold(gold:int) -> void:
	super.update_for_gold(gold)
	gui_tool_card_button.resource_sufficient = cost <= gold

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	gui_tool_card_button.toggle_tooltip(true)
	Events.update_hovered_data.emit(_weak_tool_data.get_ref())

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	gui_tool_card_button.toggle_tooltip(false)
	Events.update_hovered_data.emit(null)
