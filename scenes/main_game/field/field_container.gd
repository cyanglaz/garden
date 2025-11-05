class_name FieldContainer
extends Node2D

const PLANT_SCENE_PATH_PREFIX := "res://scenes/main_game/plants/plants/plant_"

signal mouse_plant_updated(plant:Plant)
signal field_harvest_started()
signal field_harvest_completed(index:int, plant_data:PlantData)
signal plant_hovered(hovered:bool, index:int)
signal plant_pressed(index:int)
signal field_action_application_completed(index:int)

const MAX_DISTANCE_BETWEEN_FIELDS := 15
const MARGIN := 36

const FIELD_SCENE := preload("res://scenes/main_game/field/field.tscn")

@onready var _container: Node2D = %Container

# var fields:Array[Field]: get = _get_fields
var plants:Array[Plant] = []
var mouse_plant:Plant: get = _get_mouse_plant
var _weak_mouse_plant:WeakRef = weakref(null)
var _plant_positions:Array[Vector2] = []

func update_with_number_of_fields(number_of_fields:int) -> void:
	_plant_positions = _calculate_plant_positions(number_of_fields)

func is_field_occupied(index:int) -> bool:
	return plants[index] != null

func plant_seed(plant_data:PlantData, combat_main:CombatMain) -> void:
	assert(plants.size() < _plant_positions.size() - 1, "Plant index out of bounds")
	var plant_scene_path := PLANT_SCENE_PATH_PREFIX + plant_data.id + ".tscn"
	var scene := load(plant_scene_path)
	var plant:Plant = scene.instantiate()
	_container.add_child(plant)
	plant.data = plant_data
	var plant_index := plants.size()
	plant.plant_pressed.connect(func(): plant_pressed.emit(plant_index))
	plant.plant_hovered.connect(_on_plant_hovered.bind(plant_index))
	plants.append(plant)
	await plant.plant_down(combat_main)

func trigger_end_day_field_status_hooks(combat_main:CombatMain) -> void:
	for plant:Plant in plants:
		await plant.handle_end_day_hook(combat_main)

func trigger_end_day_plant_abilities(combat_main:CombatMain) -> void:
	for plant:Plant in plants:
		await plant.trigger_ability(Plant.AbilityType.END_DAY, combat_main)

func trigger_tool_application_hook() -> void:
	for plant:Plant in plants:
		await plant.handle_tool_application_hook()
	
func trigger_tool_discard_hook(count:int) -> void:
	for plant:Plant in plants:
		await plant.handle_tool_discard_hook(count)
	
func handle_turn_end() -> void:
	for plant:Plant in plants:
		plant.handle_turn_end()

func clear_tool_indicators() -> void:
	for plant:Plant in plants:
		plant.toggle_selection_indicator(GUIFieldSelectionArrow.IndicatorState.HIDE)
	
func get_plant(index:int) -> Plant:
	if plants.size() <= index:
		return null
	return plants[index]

func get_next_empty_field_indices(number_of_fields:int) -> Array[int]:
	var result:Array[int] = []
	for i in number_of_fields:
		result.append(plants.size() + i)
	return result

func toggle_tooltip_for_plant(index:int, on:bool) -> void:
	var plant:Plant = plants[index]
	if on:
		plant.show_tooltip()
	else:
		plant.hide_tooltip()
	
func toggle_all_plants_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState) -> void:
	for plant:Plant in plants:
		plant.toggle_selection_indicator(indicator_state)

func toggle_plant_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState, index:int) -> void:
	var plant:Plant = plants[index]
	plant.toggle_selection_indicator(indicator_state)
	if indicator_state == GUIFieldSelectionArrow.IndicatorState.CURRENT:
		for other_plant:Plant in plants:
			if other_plant != plant:
				other_plant.toggle_selection_indicator(GUIFieldSelectionArrow.IndicatorState.HIDE)
	
func _calculate_plant_positions(number_of_fields:int) -> Array[Vector2]:
	if number_of_fields == 0:
		return []
	
	# Get screen size
	var screen_size = get_viewport().get_visible_rect().size
	
	# Calculate total width needed for all fields
	var total_plants_width = 0.0
	var plant_width:float = Plant.WIDTH
	total_plants_width = number_of_fields * plant_width
	
	# Calculate spacing between fields
	var available_width = screen_size.x - MARGIN * 2  # Leave 20px margin on each side
	var spacing = 0.0
	
	if number_of_fields > 1:
		var total_spacing_needed = available_width - total_plants_width
		spacing = min(total_spacing_needed / (number_of_fields - 1), MAX_DISTANCE_BETWEEN_FIELDS)
	
	# Position fields horizontally
#	
	# Calculate starting x position to center align fields
	var total_width = total_plants_width + (spacing * (number_of_fields - 1))
	var start_x = - total_width / 2 + plant_width/2
	
	var current_x = start_x
	for i in number_of_fields:
		var plant_position:Vector2 = Vector2(current_x, 0)
		_plant_positions.append(plant_position)
		current_x += plant_width + spacing
	return _plant_positions

func _get_fields() -> Array[Field]:
	var result:Array[Field] = []
	for field:Field in _container.get_children():
		result.append(field)
	return result

func _get_mouse_plant() -> Plant:
	return _weak_mouse_plant.get_ref()

func _on_plant_hovered(hovered:bool, index:int) -> void:
	if hovered:
		_weak_mouse_plant = weakref(plants[index])
		mouse_plant_updated.emit(_weak_mouse_plant.get_ref())
	else:
		_weak_mouse_plant = weakref(null)
		mouse_plant_updated.emit(null)
	plant_hovered.emit(hovered, index)
