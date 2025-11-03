class_name FieldContainer
extends Node2D

signal mouse_field_updated(field:Field)
signal field_harvest_started()
signal field_harvest_completed(index:int, plant_data:PlantData)
signal field_hovered(hovered:bool, index:int)
signal field_pressed(index:int)
signal field_action_application_completed(index:int)

const MAX_DISTANCE_BETWEEN_FIELDS := 15
const MARGIN := 36

const FIELD_SCENE := preload("res://scenes/main_game/field/field.tscn")

@onready var _container: Node2D = %Container

var fields:Array[Field]: get = _get_fields
var mouse_field:Field: get = _get_mouse_field
var _weak_mouse_field:WeakRef = weakref(null)

func update_with_number_of_fields(number_of_fields:int) -> void:
	Util.remove_all_children(_container)
	var last_field:Field = null
	for i in range(number_of_fields):
		var field:Field = FIELD_SCENE.instantiate()
		field.field_hovered.connect(_on_field_hovered.bind(i))
		field.field_pressed.connect(func(): field_pressed.emit(i))
		field.plant_harvest_started.connect(func(): field_harvest_started.emit())
		field.plant_harvest_completed.connect(func(plant_data:PlantData): field_harvest_completed.emit(i, plant_data))
		field.action_application_completed.connect(func(): field_action_application_completed.emit(i))
		if last_field:
			field.weak_left_field = weakref(last_field)
			last_field.weak_right_field = weakref(field)
		last_field = field
		_container.add_child(field)
	_layout_fields()

func is_field_occupied(index:int) -> bool:
	var field:Field = _container.get_child(index)
	return field.plant != null

func toggle_plant_preview(on:bool, plant_data:PlantData, index:int) -> void:
	var field:Field = _container.get_child(index)
	if on:
		field.show_plant_preview(plant_data)
	else:
		field.remove_plant_preview()

func plant_seed(plant_data:PlantData, combat_main:CombatMain, index:int) -> void:
	var field:Field = _container.get_child(index)
	await field.plant_seed(plant_data, combat_main)

func clear_previews() -> void:
	for field:Field in _container.get_children():
		field.remove_plant_preview()

func get_preview_icon_global_position(preview_icon:Control, index:int) -> Vector2:
	var field:Field = _container.get_child(index)
	return field.get_preview_icon_global_position(preview_icon)

func trigger_end_day_field_status_hooks(combat_main:CombatMain) -> void:
	for field:Field in _container.get_children():
		await field.handle_end_day_hook(combat_main)

func trigger_end_day_plant_abilities(combat_main:CombatMain) -> void:
	for field:Field in _container.get_children():
		if field.plant:
			await field.plant.trigger_ability(Plant.AbilityType.END_DAY, combat_main)

func trigger_tool_application_hook() -> void:
	for field:Field in _container.get_children():
		await field.handle_tool_application_hook()
	
func trigger_tool_discard_hook(count:int) -> void:
	for field:Field in _container.get_children():
		await field.handle_tool_discard_hook(count)

func clear_tool_indicators() -> void:
	for field:Field in fields:
		field.toggle_selection_indicator(GUIFieldSelectionArrow.IndicatorState.HIDE)
	
func toggle_field_selection_indicator(indicator_state: GUIFieldSelectionArrow.IndicatorState, _tool_data:ToolData, index:int) -> void:
	var field:Field = _container.get_child(index)
	field.toggle_selection_indicator(indicator_state)
	if indicator_state == GUIFieldSelectionArrow.IndicatorState.CURRENT:
		for other_field:Field in fields:
			if other_field != field:
				other_field.toggle_selection_indicator(GUIFieldSelectionArrow.IndicatorState.HIDE)
			
func toggle_all_field_selection_indicators(indicator_state: GUIFieldSelectionArrow.IndicatorState) -> void:
	for field:Field in fields:
		field.toggle_selection_indicator(indicator_state)
	
func get_field(index:int) -> Field:
	if fields.size() <= index:
		return null
	return fields[index]

func handle_turn_end() -> void:
	for field:Field in fields:
		field.handle_turn_end()

func clear_all_statuses() -> void:
	for field:Field in fields:
		field.clear_all_statuses()

func get_all_field_indices() -> Array[int]:
	var indices:Array[int] = []
	for i in fields.size():
		indices.append(i)
	return indices

func get_harvestable_fields() -> Array[int]:
	var harvestable_fields:Array[int] = []
	for i in fields.size():
		if is_field_occupied(i) && fields[i].can_harvest():
			harvestable_fields.append(i)
	return harvestable_fields

func has_plants() -> bool:
	for field:Field in _container.get_children():
		if field.plant:
			return true
	return false

func get_plants(indices:Array[int]) -> Array[Plant]:
	var plants:Array[Plant] = []
	for index:int in indices:
		plants.append(fields[index].plant)
	return plants

func toggle_tooltip_for_field(index:int, on:bool) -> void:
	var field:Field = _container.get_child(index)
	if on:
		field.show_tooltip()
	else:
		field.hide_tooltip()
	
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
	return

func _get_fields() -> Array[Field]:
	var result:Array[Field] = []
	for field:Field in _container.get_children():
		result.append(field)
	return result

func _get_mouse_field() -> Field:
	return _weak_mouse_field.get_ref()

func _on_field_hovered(hovered:bool, index:int) -> void:
	if hovered:
		_weak_mouse_field = weakref(fields[index])
		mouse_field_updated.emit(_weak_mouse_field.get_ref())
	else:
		_weak_mouse_field = weakref(null)
		mouse_field_updated.emit(null)
	field_hovered.emit(hovered, index)
