class_name GUIThingInfoItem
extends VBoxContainer

signal reference_button_evoked(reference_pair:Array)

const REFERENCE_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_tooltip_reference_button.tscn")
const RESOURCE_ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_"
const GUI_PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")
const CARD_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_card.png"
const GUI_ENEMY_SCENE := preload("res://scenes/GUI/main_game/characters/gui_enemy.tscn")
const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")
const PLANT_ABILITY_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_ability_icon.tscn")
var GUI_TOOL_CARD_BUTTON_SCENE := load("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")
var GUI_PLANT_TOOLTIP_SCENE := load("res://scenes/GUI/tooltips/gui_plant_tooltip.tscn")

var content_position_y := 0.0

func update_with_plant_data(plant_data:PlantData) -> void:
	var plant_icon:GUIPlantIcon = GUI_PLANT_ICON_SCENE.instantiate()
	add_child(plant_icon)
	plant_icon.update_with_plant_data(plant_data)
	set_deferred("content_position_y", plant_icon.position.y + plant_icon.size.y + get_theme_constant("separation"))
	var plant_tooltip:GUIPlantTooltip = GUI_PLANT_TOOLTIP_SCENE.instantiate()
	plant_tooltip.library_mode = true
	add_child(plant_tooltip)
	plant_tooltip.update_with_plant_data(plant_data)
	_find_reference_pairs_and_add_buttons(plant_data.description)
	var immune_to_status_pairs:Array = []
	for status_id in plant_data.immune_to_status:
		immune_to_status_pairs.append(["field_status", status_id])
	_add_reference_buttons(immune_to_status_pairs)
	var ability_pairs:Array = []
	for ability_id:String in plant_data.abilities:
		ability_pairs.append(["plant_ability", ability_id])
	_add_reference_buttons(ability_pairs)

func update_with_tool_data(tool_data:ToolData) -> void:
	var card_button:GUIToolCardButton = GUI_TOOL_CARD_BUTTON_SCENE.instantiate()
	add_child(card_button)
	card_button.library_mode = true
	card_button.display_mode = true
	card_button.activated = true
	card_button.mouse_disabled = false
	card_button.update_with_tool_data(tool_data)
	card_button.mouse_entered.connect(func() -> void: card_button.card_state = GUIToolCardButton.CardState.HIGHLIGHTED)
	card_button.mouse_exited.connect(func() -> void: card_button.card_state = GUIToolCardButton.CardState.NORMAL)
	_find_reference_pairs_and_add_buttons(tool_data.description)

func update_with_boss_data(boss_data:BossData) -> void:
	var boss_tooltip:GUIBossTooltip = Util.GUI_BOSS_TOOLTIP_SCENE.instantiate()
	add_child(boss_tooltip)
	boss_tooltip.library_mode = true
	boss_tooltip.update_with_boss_data(boss_data)
	_find_reference_pairs_and_add_buttons(boss_data.description)

func update_with_weather_data(weather_data:WeatherData) -> void:
	var weather_icon:GUIWeather = GUI_WEATHER_SCENE.instantiate()
	add_child(weather_icon)
	weather_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	weather_icon.setup_with_weather_data(weather_data)
	weather_icon.has_tooltip = false
	set_deferred("content_position_y", weather_icon.position.y + weather_icon.size.y + get_theme_constant("separation"))
	var weather_tooltip:GUIWeatherTooltip = Util.GUI_WEATHER_TOOLTIP_SCENE.instantiate()
	weather_tooltip.display_mode = true
	add_child(weather_tooltip)
	weather_tooltip.update_with_weather_data(weather_data)
	_find_reference_pairs_and_add_buttons(weather_data.description)

func update_with_thing_data(thing_data:ThingData) -> void:
	var thing_data_tooltip:GUIThingDataTooltip = Util.GUI_THING_DATA_TOOLTIP_SCENE.instantiate()
	add_child(thing_data_tooltip)
	thing_data_tooltip.update_with_thing_data(thing_data)
	_find_reference_pairs_and_add_buttons(thing_data.description)

func _find_reference_pairs_and_add_buttons(description:String) -> void:
	var reference_pairs:Array = DescriptionParser.find_all_reference_pairs(description)
	_add_reference_buttons(reference_pairs)

func _add_reference_buttons(reference_pairs:Array) -> void:
	for reference_pair:Array in reference_pairs:
		var category:String = reference_pair[0]
		var id:String = reference_pair[1]
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
