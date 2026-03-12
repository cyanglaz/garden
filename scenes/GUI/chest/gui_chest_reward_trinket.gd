class_name GUIChestRewardTrinket
extends GUIBasicButton

signal trinket_selected()

@onready var gui_player_trinket: GUIPlayerTrinket = $GUIPlayerTrinket

var mouse_disabled: bool = false: set = _set_mouse_disabled

func _ready() -> void:
	super._ready()
	pressed.connect(func(): trinket_selected.emit())

func update_with_trinket_data(trinket_data: TrinketData) -> void:
	gui_player_trinket.update_with_trinket_data(trinket_data)

func _set_mouse_disabled(val: bool) -> void:
	mouse_disabled = val
	mouse_filter = Control.MOUSE_FILTER_IGNORE if val else Control.MOUSE_FILTER_STOP
