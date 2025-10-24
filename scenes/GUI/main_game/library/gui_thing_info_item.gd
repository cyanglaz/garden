class_name GUIThingInfoItem
extends VBoxContainer

signal reference_button_evoked(reference_pair:Array)

const REFERENCE_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_tooltip_reference_button.tscn")
const RESOURCE_ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_"
const WEATHER_ICON_PREFIX := "res://resources/sprites/GUI/icons/weathers/icon_"
const GUI_PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const CARD_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_card.png"
const GUI_ENEMY_SCENE := preload("res://scenes/GUI/main_game/characters/gui_enemy.tscn")
const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")
const PLANT_ABILITY_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_ability_icon.tscn")
const ONE_ACTION_DESCRIPTION_SCENE := preload("res://scenes/GUI/shared/descriptions/shared_description/gui_one_action_description.tscn")
var GUI_TOOL_CARD_BUTTON_SCENE := load("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
var GUI_PLANT_TOOLTIP_SCENE := load("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")

var content_position_y := 0.0

func update_with_plant_data(plant_data:PlantData) -> void:
	var plant_icon:GUIPlantIcon = GUI_PLANT_ICON_SCENE.instantiate()
	add_child(plant_icon)
	plant_icon.update_with_plant_data(plant_data)
	set_deferred("content_position_y", plant_icon.position.y + plant_icon.size.y + get_theme_constant("separation"))
	var plant_tooltip:GUIPlantTooltip = GUI_PLANT_TOOLTIP_SCENE.instantiate()
	plant_tooltip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	add_child(plant_tooltip)
	plant_tooltip.update_with_plant_data(plant_data)
	_find_reference_pairs_and_add_buttons(plant_data.description)
	var ability_pairs:Array = []
	for ability_id:String in plant_data.abilities:
		ability_pairs.append(["plant_ability", ability_id])
	_add_reference_buttons(ability_pairs)

func update_with_tool_data(tool_data:ToolData) -> void:
	var card_button:GUIToolCardButton = GUI_TOOL_CARD_BUTTON_SCENE.instantiate()
	add_child(card_button)
	card_button.mouse_disabled = true
	card_button.update_with_tool_data(tool_data)
	card_button.mouse_entered.connect(func() -> void: card_button.card_state = GUIToolCardButton.CardState.HIGHLIGHTED)
	card_button.mouse_exited.connect(func() -> void: card_button.card_state = GUIToolCardButton.CardState.NORMAL)
	card_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_find_reference_pairs_and_add_buttons(tool_data.description)
	var action_pairs:Array = []
	for action_data:ActionData in tool_data.actions:
		action_pairs.append(["action", action_data])
	_add_reference_buttons(action_pairs)
	var special_pairs:Array = []
	for special:ToolData.Special in tool_data.specials:
		special_pairs.append(["special", Util.get_id_for_tool_speical(special)])
	_add_reference_buttons(special_pairs)

func update_with_action_data(action_data:ActionData) -> void:
	var action_tooltip:GUIActionsTooltip = Util.GUI_ACTIONS_TOOLTIP_SCENE.instantiate()
	add_child(action_tooltip)
	action_tooltip.update_with_actions([action_data], null)
	action_tooltip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_find_reference_pairs_and_add_buttons(ActionDescriptionFormulator.get_action_description(action_data, null))

func update_with_special_data(special:ToolData.Special) -> void:
	var special_tooltip:GUIActionsTooltip = Util.GUI_ACTIONS_TOOLTIP_SCENE.instantiate()
	add_child(special_tooltip)
	special_tooltip.update_with_special(special)
	special_tooltip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_find_reference_pairs_and_add_buttons(ActionDescriptionFormulator.get_special_description(special))

func update_with_boss_data(boss_data:BossData) -> void:
	var boss_tooltip:GUIBossTooltip = Util.GUI_BOSS_TOOLTIP_SCENE.instantiate()
	add_child(boss_tooltip)
	boss_tooltip.update_with_boss_data(boss_data)
	boss_tooltip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_find_reference_pairs_and_add_buttons(boss_data.description)

func update_with_weather_data(weather_data:WeatherData) -> void:
	var weather_tooltip:GUIWeatherTooltip = Util.GUI_WEATHER_TOOLTIP_SCENE.instantiate()
	weather_tooltip.display_mode = false
	weather_tooltip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	add_child(weather_tooltip)
	weather_tooltip.update_with_weather_data(weather_data)
	_find_reference_pairs_and_add_buttons(weather_data.description)
	var action_pairs:Array = []
	for action_data:ActionData in weather_data.actions:
		action_pairs.append(["action", action_data])
	_add_reference_buttons(action_pairs)

func update_with_thing_data(thing_data:ThingData) -> void:
	var thing_data_tooltip:GUIThingDataTooltip = Util.GUI_THING_DATA_TOOLTIP_SCENE.instantiate()
	add_child(thing_data_tooltip)
	thing_data_tooltip.update_with_thing_data(thing_data)
	thing_data_tooltip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_find_reference_pairs_and_add_buttons(thing_data.description)

func _find_reference_pairs_and_add_buttons(description:String) -> void:
	var reference_pairs:Array = DescriptionParser.find_all_reference_pairs(description)
	_add_reference_buttons(reference_pairs)

func _add_reference_buttons(reference_pairs:Array) -> void:
	for reference_pair:Array in reference_pairs:
		var category:String = reference_pair[0]
		var id:String = ""
		if category == "action":
			id = Util.get_action_id_with_action_type(reference_pair[1].type)
		else:
			id = reference_pair[1]
		if category == "resource" || category == "bordered_text":
			continue
		var reference_button:GUITooltipReferenceButton = REFERENCE_BUTTON_SCENE.instantiate()
		add_child(reference_button)
		var icon_path:String = _get_reference_button_icon_path(category, id)
		var display_name:String = _get_reference_name(category, id)
		reference_button.update_with_icon(icon_path, display_name)
		reference_button.pressed.connect(_on_reference_button_evoked.bind(reference_pair, reference_button))
		reference_button.button_state = GUIBasicButton.ButtonState.NORMAL
	
func _get_reference_button_icon_path(category:String, id:String) -> String:
	match category:
		"field_status":
			return str(RESOURCE_ICON_PREFIX, id, ".png")
		"action":
			return str(RESOURCE_ICON_PREFIX, id, ".png")
		"card":
			return CARD_ICON_PATH
		"plant_ability":
			return str(RESOURCE_ICON_PREFIX, id, ".png")
		"weather":
			return str(WEATHER_ICON_PREFIX, id, ".png")
		"special":
			return str(RESOURCE_ICON_PREFIX, id, ".png")
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
		"plant_ability":
			return MainDatabase.plant_ability_database.get_data_by_id(id).display_name
		"weather":
			return MainDatabase.weather_database.get_data_by_id(id).display_name
		"special":
			return ActionDescriptionFormulator.get_special_name(Util.get_special_from_id(id))
		_:
			assert(false, "category not implemented")
	return ""

func _on_reference_button_evoked(reference_pair:Array, button:GUITooltipReferenceButton) -> void:
	for child:Control in get_children():
		if child == button:
			child.button_state = GUIBasicButton.ButtonState.SELECTED
			continue
		elif child is GUITooltipReferenceButton:
			child.button_state = GUIBasicButton.ButtonState.NORMAL
	reference_button_evoked.emit(reference_pair)
