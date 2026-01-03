class_name PlantFieldContainer
extends FieldContainer

const FIELD_SCENE := preload("res://scenes/main_game/combat/fields/plant_field.tscn")

signal mouse_plant_updated(plant:Plant)
signal plant_bloom_started()
signal plant_bloom_completed()
signal plant_action_application_completed(index:int)

const PLANT_ICON_OFFSET := Vector2.UP * 4

# var fields:Array[Field]: get = _get_fields
var plants:Array[Plant] = []
var mouse_plant:Plant: get = _get_mouse_plant
var _weak_mouse_plant:WeakRef = weakref(null)

func setup_with_plants(plant_datas:Array) -> void:
	var current_field:Field = null
	for i in plant_datas.size():
		var field:Field = FIELD_SCENE.instantiate()
		field.plant_bloom_started.connect(func(): plant_bloom_started.emit())
		field.plant_bloom_completed.connect(func(): plant_bloom_completed.emit())
		field.action_application_completed.connect(func(): plant_action_application_completed.emit(i))
		field.index = i
		add_child(field)
		var plant_data:PlantData = plant_datas[i]
		field.plant_seed(plant_data)
		plants.append(field.plant)

		if current_field:
			field.left_field = current_field
			current_field.right_field = field
		current_field = field
	setup_fields()

func generate_next_attacks(combat_main:CombatMain) -> void:
	for plant:Plant in plants:
		plant.generate_next_attacks(combat_main)

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
	
func get_plant(index:int) -> Plant:
	if plants.size() <= index:
		return null
	return plants[index]

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
	return Util.get_node_canvas_position(self) + field_position + Vector2.LEFT * preview_icon.size.x/2 + Vector2.UP * preview_icon.size.y + PLANT_ICON_OFFSET
	
func are_all_plants_bloom() -> bool:
	for plant in plants:
		if !plant.is_bloom():
			return false
	return true

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
	super._on_field_hovered(hovered, index)
