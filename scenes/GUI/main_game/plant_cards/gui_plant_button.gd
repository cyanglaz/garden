class_name GUIPlantButton
extends GUIBasicButton

@onready var _gui_plant_icon: GUIPlantIcon = %GUIPlantIcon

func update_with_plant_data(plant_data:PlantData) -> void:
	_gui_plant_icon.update_with_plant_data(plant_data)

func _set_button_state(state:GUIBasicButton.ButtonState) -> void:
	super._set_button_state(state)
	if _gui_plant_icon:
		match button_state:
			GUIBasicButton.ButtonState.NORMAL, GUIBasicButton.ButtonState.PRESSED, GUIBasicButton.ButtonState.SELECTED, GUIBasicButton.ButtonState.DISABLED:
				_gui_plant_icon.highlighted = false
			GUIBasicButton.ButtonState.HOVERED:
				_gui_plant_icon.highlighted = true
