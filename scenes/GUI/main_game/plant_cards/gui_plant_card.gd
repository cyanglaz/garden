class_name GUIPlantCard
extends PanelContainer

const ACTIVE_BORDER_COLOR := Constants.COLOR_BLUE_1
const FINISHED_BORDER_COLOR := Constants.COLOR_GREEN4

enum Mode {
	INACTIVE,
	ACTIVE,
	FINISHED,
}

@onready var gui_plant_icon: GUIPlantIcon = %GUIPlantIcon
@onready var overlay: NinePatchRect = %Overlay
@onready var highlight_border: NinePatchRect = %HighlightBorder

var mode:Mode: set = _set_mode

func _ready() -> void:
	mode = Mode.INACTIVE
	overlay.hide()

func update_with_plant_data(pd:PlantData) -> void:
	gui_plant_icon.update_with_plant_data(pd)

func _set_mode(val:Mode) -> void:
	mode = val
	match mode:
		Mode.INACTIVE:
			highlight_border.hide()
			overlay.hide()
		Mode.ACTIVE:
			highlight_border.show()
			overlay.hide()
			highlight_border.self_modulate = ACTIVE_BORDER_COLOR
		Mode.FINISHED:
			highlight_border.show()
			highlight_border.self_modulate = FINISHED_BORDER_COLOR
			overlay.show()
