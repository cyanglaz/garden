class_name FieldContainer
extends Node2D

const MAX_DISTANCE_BETWEEN_FIELDS := 28
const MARGIN := 36
const MAX_FIELDS := 5

signal field_hovered(hovered:bool, index:int)
signal field_pressed(index:int)

var fields:Array[Field] = []

func setup_fields() -> void:
	assert(get_child_count() <= MAX_FIELDS, "Field container can only have %s fields" % MAX_FIELDS)
	for i in get_child_count():
		var field:Field = get_child(i)
		fields.append(field)
		field.field_hovered.connect(_on_field_hovered.bind(i))
		field.field_pressed.connect(_on_field_pressed.bind(i))
	_layout_fields.call_deferred()

func clear_tool_indicators() -> void:
	for field:Field in fields:
		field.toggle_selection_indicator(GUIFieldSelectionArrow.IndicatorState.HIDE)
	
func get_field(index:int) -> Field:
	if fields.size() <= index:
		return null
	return fields[index]

func _layout_fields() -> void:
	if fields.size() == 0:
		return
	
	# Get screen size
	var screen_size = get_viewport().get_visible_rect().size
	
	# Calculate total width needed for all fields
	var total_fields_width = 0.0
	for field:Field in fields:
		total_fields_width += field.land_width
	
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
	var start_x = - total_width / 2 + fields[0].land_width/2
	
	var current_x = start_x
	var index = 0
	for field in fields:
		field.position.x = current_x
		field.position.y = 0
		var next_field_width := 0.0
		if index < fields.size() - 1:
			next_field_width = fields[index + 1].land_width
		current_x += (field.land_width + next_field_width)/2.0 + spacing
		index += 1

func _on_field_hovered(hovered:bool, index:int) -> void:
	field_hovered.emit(hovered, index)

func _on_field_pressed(index:int) -> void:
	field_pressed.emit(index)
