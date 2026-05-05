class_name GUITrinketShopButton
extends GUIShopButton

@onready var gui_player_trinket: GUIPlayerTrinket = %GUIPlayerTrinket

var _weak_trinket_data: WeakRef = weakref(null)

func update_with_trinket_data(trinket_data: TrinketData) -> void:
	_weak_trinket_data = weakref(trinket_data)
	gui_player_trinket.update_with_trinket_data(trinket_data)
	gui_player_trinket.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost = trinket_data.cost

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	Events.request_display_tooltip.emit(
		TooltipRequest.new(TooltipRequest.TooltipType.THING_DATA, _weak_trinket_data.get_ref(), "", self, GUITooltip.TooltipPosition.TOP_RIGHT)
	)
	Events.update_hovered_data.emit(_weak_trinket_data.get_ref())

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	Events.request_hide_tooltip.emit("")
	Events.update_hovered_data.emit(null)
