class_name GUIThingInfoView
extends Control

const INFO_ITEM_SCENE := preload("res://scenes/GUI/main_game/library/gui_thing_info_item.tscn")
const PADDING := 4
const OFFSCREEN_PADDING := 6

@onready var _tooltip_container: Control = %TooltipContainer
@onready var _back_button: GUIRichTextButton = %BackButton

var stack:Array = []
var _item_y_position := 0.0

func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_evoked)
	
	#show_with_data(MainDatabase.plant_database.get_data_by_id("rose"))

func show_with_data(data:Variant) -> void:
	update_with_data(data, 0)
	if Singletons.main_game:
		Singletons.main_game.clear_all_tooltips()
	PauseManager.try_pause()
	show()

func update_with_data(data:Variant, index_level:int) -> void:
	if data == null:
		return
	_clear_tooltips(index_level)
	stack.append(data)
	for i:int in stack.size():
		if i < index_level:
			continue
		var data_to_show:Variant = stack[i]
		if data_to_show is PlantData:
			_update_with_plant_data(data_to_show, i)
		elif data_to_show is ToolData:
			_update_with_tool_data(data_to_show, i)
		elif data_to_show is BossData:
			_update_with_boss_data(data_to_show, i)
		elif data_to_show is WeatherData:
			_update_with_weather_data(data_to_show, i)
		elif data_to_show is FieldStatusData || data_to_show is PowerData || data_to_show is PlantAbilityData:
			_update_with_thing_data(data_to_show, i)
		elif data_to_show is ActionData:
			_update_with_action_data(data_to_show, i)
		elif data_to_show is ToolData.Special:
			_update_with_special_data(data_to_show, i)

func _update_with_plant_data(plant_data:PlantData, level_index:int) -> void:
	var item:GUIThingInfoItem = INFO_ITEM_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_plant_data(plant_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	_set_item_position.call_deferred(item)

func _update_with_tool_data(tool_data:ToolData, level_index:int) -> void:
	var item:GUIThingInfoItem = INFO_ITEM_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_tool_data(tool_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	_set_item_position.call_deferred(item)

func _update_with_boss_data(boss_data:BossData, level_index:int) -> void:
	var item:GUIThingInfoItem = INFO_ITEM_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_boss_data(boss_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	_set_item_position.call_deferred(item)

func _update_with_weather_data(weather_data:WeatherData, level_index:int) -> void:
	var item:GUIThingInfoItem = INFO_ITEM_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_weather_data(weather_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	_set_item_position.call_deferred(item)

func _update_with_thing_data(thing_data:ThingData, level_index:int) -> void:
	var item:GUIThingInfoItem = INFO_ITEM_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_thing_data(thing_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	_set_item_position.call_deferred(item)

func _update_with_action_data(action_data:ActionData, level_index:int) -> void:
	var item:GUIThingInfoItem = INFO_ITEM_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_action_data(action_data)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	_set_item_position.call_deferred(item)

func _update_with_special_data(special:ToolData.Special, level_index:int) -> void:
	var item:GUIThingInfoItem = INFO_ITEM_SCENE.instantiate()
	_tooltip_container.add_child(item)
	item.update_with_special_data(special)
	item.reference_button_evoked.connect(_on_reference_button_evoked.bind(level_index))
	_set_item_position.call_deferred(item)

func _set_item_position(item:GUIThingInfoItem) -> void:
	if _tooltip_container.get_child_count() == 1:
		item.position = _tooltip_container.size/2 - item.size/2
		_item_y_position = item.position.y + item.content_position_y
	else:
		var last_item:GUIThingInfoItem = _tooltip_container.get_child(_tooltip_container.get_child_count() - 2)
		var last_item_position:Vector2 = last_item.position + Vector2(0, last_item.content_position_y)
		item.position = Vector2(last_item_position.x + last_item.size.x + PADDING, _item_y_position - item.content_position_y)
	var off_screen_x := item.get_screen_position().x + item.size.x + OFFSCREEN_PADDING - get_viewport_rect().size.x
	if off_screen_x > 0:
		for child in _tooltip_container.get_children():
			child.position.x -= off_screen_x

func _clear_tooltips(from_level:int) -> void:
	while _tooltip_container.get_child_count() > from_level:
		var last_index := _tooltip_container.get_child_count()-1
		var child:GUIThingInfoItem = _tooltip_container.get_child(last_index)
		_tooltip_container.remove_child(child)
		child.queue_free()
	while stack.size() > from_level:
		stack.pop_back()

func _on_reference_button_evoked(reference_pair:Array, level:int) -> void:
	var data:Variant
	if reference_pair[0] == "plant":
		data = MainDatabase.plant_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "card":
		data = MainDatabase.tool_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "level":
		data = MainDatabase.level_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "field_status":
		data = MainDatabase.field_status_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "power":
		data = MainDatabase.power_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "plant_ability":
		data = MainDatabase.plant_ability_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "action":
		data = reference_pair[1]
	elif reference_pair[0] == "weather":
		data = MainDatabase.weather_database.get_data_by_id(reference_pair[1])
	elif reference_pair[0] == "special":
		data = Util.get_special_from_id(reference_pair[1]) as ToolData.Special
	update_with_data(data, level + 1)

func _on_back_button_evoked() -> void:
	hide()
	_clear_tooltips(0)
	PauseManager.try_unpause()
