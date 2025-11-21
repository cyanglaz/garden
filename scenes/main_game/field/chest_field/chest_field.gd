class_name ChestField
extends Field

signal chest_opened(chest: Chest)

const CHEST_OPEN_DELAY := 0.6

@onready var chest: Chest = %Chest
var _opened := false

func _ready() -> void:
	super._ready()
	toggle_selection_indicator(GUIFieldSelectionArrow.IndicatorState.READY)
	field_pressed.connect(_on_field_pressed)
	field_hovered.connect(_on_field_hovered)

func _on_field_hovered(hovered:bool) -> void:
	if hovered:
		chest.highlighted = true
	else:
		chest.highlighted = false

func _on_field_pressed() -> void:
	if _opened:
		return
	_opened = true
	chest.open()
	await Util.create_scaled_timer(CHEST_OPEN_DELAY).timeout
	chest_opened.emit(chest)
