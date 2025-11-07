class_name FieldContainer
extends Node2D

const FIELD_SCENE := preload("res://scenes/main_game/field/field.tscn")

signal mouse_plant_updated(plant:Plant)
signal plant_bloom_started()
signal plant_bloom_completed()
signal field_hovered(hovered:bool, index:int)
signal field_pressed(index:int)
signal plant_action_application_completed(index:int)

const MAX_DISTANCE_BETWEEN_FIELDS := 15
const MARGIN := 36

@onready var _container: Node2D = %Container

# var fields:Array[Field]: get = _get_fields
var plants:Array[Plant] = []
var fields:Array[Field] = []
var mouse_plant:Plant: get = _get_mouse_plant
var _active_field_index := 0
var _weak_mouse_plant:WeakRef = weakref(null)

func update_with_number_of_fields(number_of_fields:int) -> void:
	var current_field:Field = null
	for i in number_of_fields:
		var field:Field = FIELD_SCENE.instantiate()
		field.field_hovered.connect(_on_field_hovered.bind(i))
		field.field_pressed.connect(func(): field_pressed.emit(i))
		field.plant_bloom_started.connect(func(): plant_bloom_started.emit())
		field.plant_bloom_completed.connect(func(): plant_bloom_completed.emit())
		field.action_application_completed.connect(func(): plant_action_application_completed.emit(i))
		field.index = i
		_container.add_child(field)
		field.hide()
		fields.append(field)
		if current_field:
			field.left_field = current_field
			current_field.right_field = field
		current_field = field
	_layout_fields.call_deferred()

func show_next_fields(number_of_fields:int) -> void:
	for i in range(_active_field_index, _active_field_index + number_of_fields):
		fields[i].show()
		_active_field_index += 1

func plant_seed(plant_data:PlantData) -> void:
	assert(plants.size() < fields.size(), "Plant index out of bounds")
	var plant_index := plants.size()
	var target_field:Field = fields[plant_index]
	target_field.plant_seed(plant_data)
	plants.append(target_field.plant)

func trigger_end_turn_hooks(combat_main:CombatMain) -> void:
	for plant:Plant in plants:
		await plant.handle_end_turn_hook(combat_main)

func trigger_start_turn_hooks(combat_main:CombatMain) -> void:
	for plant:Plant in plants:
		await plant.handle_start_turn_hook(combat_main)

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
	for field:Field in fields:
		field.toggle_selection_indicator(GUIFieldSelectionArrow.IndicatorState.HIDE)
	
func get_plant(index:int) -> Plant:
	if plants.size() <= index:
		return null
	return plants[index]

func get_field(index:int) -> Field:
	if fields.size() <= index:
		return null
	return fields[index]

func toggle_tooltip_for_plant(index:int, on:bool) -> void:
	var field:Field = fields[index]
	if on:
		field.show_tooltip()
	else:
		field.hide_tooltip()
	
func toggle_all_plants_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState) -> void:
	for field:Field in fields:
		field.toggle_selection_indicator(indicator_state)

func toggle_plant_selection_indicator(indicator_state:GUIFieldSelectionArrow.IndicatorState, index:int) -> void:
	var field:Field = fields[index]
	field.toggle_selection_indicator(indicator_state)
	if indicator_state == GUIFieldSelectionArrow.IndicatorState.CURRENT:
		for other_field:Field in fields:
			if other_field != field:
				other_field.toggle_selection_indicator(GUIFieldSelectionArrow.IndicatorState.HIDE)

func get_preview_icon_global_position(preview_icon:Control, index:int) -> Vector2:
	var field_position := fields[index].position
	return Util.get_node_canvas_position(self) + field_position + Vector2.LEFT * preview_icon.size.x/2 + Vector2.UP * preview_icon.size.y/2
	
func _layout_fields() -> void:
	if fields.size() == 0:
		return
	
	# Get screen size
	var screen_size = get_viewport().get_visible_rect().size
	
	# Calculate total width needed for all fields
	var total_fields_width = 0.0
	var field_width:float = fields[0]._gui_field_button.size.x
	for field:Field in fields:
		total_fields_width += field_width
	
	# Calculate spacing between fields
	var available_width = screen_size.x - MARGIN * 2  # Leave 20px margin on each side
	var spacing = 0.0
	
	if fields.size() > 1:
		var total_spacing_needed = available_width - total_fields_width
		spacing = min(total_spacing_needed / (fields.size() - 1), MAX_DISTANCE_BETWEEN_FIELDS)
	
	# Position fields horizontally
#	
	# Calculate starting x position to center align fields
	var total_width = total_fields_width + (spacing * (fields.size() - 1))
	var start_x = - total_width / 2 + field_width/2
	
	var current_x = start_x
	for field in fields:
		field.position.x = current_x
		field.position.y = 0
		current_x += field_width + spacing

func _get_mouse_plant() -> Plant:
	return _weak_mouse_plant.get_ref()

func _on_field_hovered(hovered:bool, index:int) -> void:
	if index >= plants.size():
		return
	if hovered:
		_weak_mouse_plant = weakref(plants[index])
		mouse_plant_updated.emit(_weak_mouse_plant.get_ref())
	else:
		_weak_mouse_plant = weakref(null)
		mouse_plant_updated.emit(null)
	field_hovered.emit(hovered, index)
