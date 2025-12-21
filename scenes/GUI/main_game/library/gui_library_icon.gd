class_name GUILibraryIcon
extends PanelContainer

signal button_evoked(data:Resource)

const GUI_TOOL_CARD_BUTTON_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const GUI_FIELD_STATUS_ICON_SCENE := preload("res://scenes/main_game/combat/fields/gui_field_status_icon.tscn")
const GUI_POWER_ICON_SCENE := preload("res://scenes/GUI/main_game/power/gui_power_icon.tscn")

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND

func update_with_plant_data(plant_data:PlantData) -> void:
	var wrapper_button:GUIBasicButton = GUIBasicButton.new()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(plant_data))
	var plant_icon:GUIPlantIcon = PLANT_ICON_SCENE.instantiate()
	wrapper_button.add_child(plant_icon)
	plant_icon.update_with_plant_data(plant_data)
	plant_icon.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	wrapper_button.mouse_entered.connect(func() -> void: plant_icon.has_outline = true)
	wrapper_button.mouse_exited.connect(func() -> void: plant_icon.has_outline = false)

func update_with_tool_data(tool_data:ToolData) -> void:
	var wrapper_button:GUIBasicButton = GUIBasicButton.new()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(tool_data))
	var tool_card_button:GUIToolCardButton = GUI_TOOL_CARD_BUTTON_SCENE.instantiate()
	wrapper_button.add_child(tool_card_button)
	tool_card_button.update_with_tool_data(tool_data)
	tool_card_button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	wrapper_button.hover_sound = tool_card_button.hover_sound
	wrapper_button.click_sound = tool_card_button.click_sound
	wrapper_button.mouse_entered.connect(func() -> void: tool_card_button.card_state = GUICardFace.CardState.HIGHLIGHTED)
	wrapper_button.mouse_exited.connect(func() -> void: tool_card_button.card_state = GUICardFace.CardState.NORMAL)

func update_with_field_status_data(field_status_data:FieldStatusData) -> void:
	var wrapper_button:GUIBasicButton = GUIBasicButton.new()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(field_status_data))
	var field_status_icon:GUIFieldStatusIcon = GUI_FIELD_STATUS_ICON_SCENE.instantiate()
	wrapper_button.add_child(field_status_icon)
	field_status_icon.setup_with_field_status_data(field_status_data, 0)
	field_status_icon.display_mode = true
	field_status_icon.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	wrapper_button.mouse_entered.connect(func() -> void: field_status_icon.is_highlighted = true)
	wrapper_button.mouse_exited.connect(func() -> void: field_status_icon.is_highlighted = false)

func update_with_power_data(power_data:PowerData) -> void:
	var wrapper_button:GUIBasicButton = GUIBasicButton.new()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(power_data))
	var power_icon:GUIPowerIcon = GUI_POWER_ICON_SCENE.instantiate()
	wrapper_button.add_child(power_icon)
	power_icon.display_mode = true
	power_icon.setup_with_power_data(power_data)
	power_icon.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	wrapper_button.mouse_entered.connect(func() -> void: power_icon.is_highlighted = true)
	wrapper_button.mouse_exited.connect(func() -> void: power_icon.is_highlighted = false)
