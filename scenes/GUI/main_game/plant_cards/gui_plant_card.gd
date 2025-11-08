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

var mode:Mode: set = _set_mode

func _ready() -> void:
	mode = Mode.INACTIVE
	overlay.hide()

func update_with_plant_data(pd:PlantData) -> void:
	gui_plant_icon.update_with_plant_data(pd)

func remove_texture() -> void:
	gui_plant_icon.remove_texture()

func _set_mode(val:Mode) -> void:
	mode = val
	match mode:
		Mode.INACTIVE:
			gui_plant_icon.has_outline = false
			overlay.hide()
		Mode.ACTIVE:
			gui_plant_icon.has_outline = true
			overlay.hide()
			gui_plant_icon.outline_color = ACTIVE_BORDER_COLOR
		Mode.FINISHED:
			gui_plant_icon.has_outline = true
			gui_plant_icon.outline_color = FINISHED_BORDER_COLOR
			overlay.show()
