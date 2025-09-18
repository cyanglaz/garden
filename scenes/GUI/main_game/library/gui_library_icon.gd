class_name GUILibraryIcon
extends PanelContainer

signal button_evoked(data:Resource)

const WRAPPER_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_library_item_wrapper_button.tscn")
const GUI_TOOL_CARD_BUTTON_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
const PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const GUI_ENEMY_SCENE := preload("res://scenes/GUI/main_game/characters/gui_enemy.tscn")
const GUI_FIELD_STATUS_ICON_SCENE := preload("res://scenes/main_game/field/gui_field_status_icon.tscn")
const GUI_POWER_ICON_SCENE := preload("res://scenes/GUI/main_game/power/gui_power_icon.tscn")

func update_with_plant_data(plant_data:PlantData) -> void:
	var wrapper_button:GUILibraryItemWrapperButton = WRAPPER_BUTTON_SCENE.instantiate()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(plant_data))
	var plant_icon:GUIPlantIcon = PLANT_ICON_SCENE.instantiate()
	wrapper_button.add_item(plant_icon)
	plant_icon.update_with_plant_data(plant_data)
	wrapper_button.mouse_entered.connect(func() -> void: plant_icon.has_outline = true)
	wrapper_button.mouse_exited.connect(func() -> void: plant_icon.has_outline = false)

func update_with_tool_data(tool_data:ToolData) -> void:
	var wrapper_button:GUILibraryItemWrapperButton = WRAPPER_BUTTON_SCENE.instantiate()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(tool_data))
	var tool_card_button:GUIToolCardButton = GUI_TOOL_CARD_BUTTON_SCENE.instantiate()
	wrapper_button.add_item(tool_card_button)
	tool_card_button.update_with_tool_data(tool_data)
	wrapper_button.mouse_entered.connect(func() -> void: tool_card_button.button_state = GUIBasicButton.ButtonState.HOVERED)
	wrapper_button.mouse_exited.connect(func() -> void: tool_card_button.button_state = GUIBasicButton.ButtonState.NORMAL)

func update_with_level_data(level_data:LevelData) -> void:
	var wrapper_button:GUILibraryItemWrapperButton = WRAPPER_BUTTON_SCENE.instantiate()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(level_data))
	var enemy:GUIEnemy = GUI_ENEMY_SCENE.instantiate()
	wrapper_button.add_item(enemy)
	enemy.update_with_level_data(level_data)
	wrapper_button.mouse_entered.connect(func() -> void: enemy.has_outline = true)
	wrapper_button.mouse_exited.connect(func() -> void: enemy.has_outline = false)

func update_with_field_status_data(field_status_data:FieldStatusData) -> void:
	var wrapper_button:GUILibraryItemWrapperButton = WRAPPER_BUTTON_SCENE.instantiate()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(field_status_data))
	var field_status_icon:GUIFieldStatusIcon = GUI_FIELD_STATUS_ICON_SCENE.instantiate()
	wrapper_button.add_item(field_status_icon)
	field_status_icon.update_with_field_status_data(field_status_data)
	wrapper_button.mouse_entered.connect(func() -> void: field_status_icon.is_highlighted = true)
	wrapper_button.mouse_exited.connect(func() -> void: field_status_icon.is_highlighted = false)

func update_with_power_data(power_data:PowerData) -> void:
	var wrapper_button:GUILibraryItemWrapperButton = WRAPPER_BUTTON_SCENE.instantiate()
	add_child(wrapper_button)
	wrapper_button.pressed.connect(func() -> void: button_evoked.emit(power_data))
	var power_icon:GUIPowerIcon = GUI_POWER_ICON_SCENE.instantiate()
	wrapper_button.add_item(power_icon)
	power_icon.update_with_power_data(power_data)
	wrapper_button.mouse_entered.connect(func() -> void: power_icon.is_highlighted = true)
	wrapper_button.mouse_exited.connect(func() -> void: power_icon.is_highlighted = false)
