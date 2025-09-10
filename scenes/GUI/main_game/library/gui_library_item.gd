class_name GUILibraryItem
extends VBoxContainer

signal reference_button_evoked(reference_pair:Array)
signal tooltip_button_evoked(data:Resource)

const REFERENCE_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_tooltip_reference_button.tscn")
const PLANT_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")
const CARD_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_card_tooltip.tscn")
const TOOL_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_tool_card_tooltip.tscn")
const BOSS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_boss_tooltip.tscn")
const FIELD_STATUS_TOOLTIP_SCENE := preload("res://scenes/GUI/tooltips/gui_field_status_tooltip.tscn")

const RESOURCE_ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_"
const CARD_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_card.png"

func update_with_plant_data(plant_data:PlantData) -> void:
	var plant_tooltip:GUIPlantTooltip = PLANT_TOOLTIP_SCENE.instantiate()
	var tooltip_button:GUIBasicButton = _create_tooltip_button(plant_tooltip, plant_data)
	add_child(tooltip_button)
	plant_tooltip.update_with_plant_data(plant_data)
	_find_reference_pairs_and_add_buttons(plant_data.description)
	var immune_to_status_pairs:Array = []
	for status_id in plant_data.immune_to_status:
		immune_to_status_pairs.append(["field_status", status_id])
	_add_reference_buttons(immune_to_status_pairs)

func update_with_tool_data(tool_data:ToolData) -> void:
	var h_box_container:HBoxContainer = HBoxContainer.new()
	h_box_container.add_theme_constant_override("separation", 1)
	add_child(h_box_container)
	var tool_tooltip:GUICardTooltip = CARD_TOOLTIP_SCENE.instantiate()
	var tooltip_button:GUIBasicButton = _create_tooltip_button(tool_tooltip, tool_data)
	h_box_container.add_child(tooltip_button)
	tool_tooltip.update_with_tool_data(tool_data)
	if !tool_data.actions.is_empty():
		var tool_card_tooltip:GUIToolCardTooltip = TOOL_TOOLTIP_SCENE.instantiate()
		tool_card_tooltip.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		h_box_container.add_child(tool_card_tooltip)
		tool_card_tooltip.update_with_tool_data(tool_data)
	_find_reference_pairs_and_add_buttons(tool_data.description)

func update_with_level_data(level_data:LevelData) -> void:
	var boss_tooltip:GUIBossTooltip = BOSS_TOOLTIP_SCENE.instantiate()
	var tooltip_button:GUIBasicButton = _create_tooltip_button(boss_tooltip, level_data)
	add_child(tooltip_button)
	boss_tooltip.update_with_level_data(level_data)
	_find_reference_pairs_and_add_buttons(level_data.description)

func update_with_field_status_data(field_status_data:FieldStatusData) -> void:
	var field_status_tooltip:GUIFieldStatusTooltip = FIELD_STATUS_TOOLTIP_SCENE.instantiate()
	var tooltip_button:GUIBasicButton = _create_tooltip_button(field_status_tooltip, field_status_data)
	add_child(tooltip_button)
	field_status_tooltip.update_with_field_status_data(field_status_data)
	_find_reference_pairs_and_add_buttons(field_status_data.description)

func _create_tooltip_button(control:Control, data:Resource) -> GUIBasicButton:
	control.mouse_filter = Control.MOUSE_FILTER_PASS
	var basic_button:GUIBasicButton = GUIBasicButton.new()
	basic_button.action_evoked.connect(func(): tooltip_button_evoked.emit(data))
	basic_button.add_child(control)
	basic_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return basic_button

func _find_reference_pairs_and_add_buttons(description:String) -> void:
	var reference_pairs:Array = DescriptionParser.find_all_reference_pairs(description)
	_add_reference_buttons(reference_pairs)

func _add_reference_buttons(reference_pairs:Array) -> void:
	for reference_pair:Array in reference_pairs:
		var category:String = reference_pair[0]
		var id:String = reference_pair[1]
		if category == "resource":
			continue
		var reference_button:GUITooltipReferenceButton = REFERENCE_BUTTON_SCENE.instantiate()
		add_child(reference_button)
		var icon_path:String = _get_reference_button_icon_path(category, id)
		var display_name:String = _get_reference_name(category, id)
		reference_button.update_with_icon(icon_path, display_name)
		reference_button.action_evoked.connect(func(): reference_button_evoked.emit(reference_pair))
	
func _get_reference_button_icon_path(category:String, id:String) -> String:
	match category:
		"field_status":
			return str(RESOURCE_ICON_PREFIX, id, ".png")
		"action":
			return str(RESOURCE_ICON_PREFIX, id, ".png")
		"card":
			return CARD_ICON_PATH
		_:
			assert(false, "category not implemented")
	return ""

func _get_reference_name(category:String, id:String) -> String:
	match category:
		"field_status":
			return MainDatabase.field_status_database.get_data_by_id(id).display_name
		"action":
			var action_type:ActionData.ActionType = Util.get_action_type_from_action_id(id)
			return Util.get_action_name_from_action_type(action_type)
		"card":
			return MainDatabase.tool_database.get_data_by_id(id).display_name
		_:
			assert(false, "category not implemented")
	return ""
