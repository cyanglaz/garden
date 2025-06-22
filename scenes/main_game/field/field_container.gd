class_name FieldContainer
extends Node2D

const MAX_DISTANCE_BETWEEN_FIELDS := 20
const MARGIN := 36

const FIELD_SCENE := preload("res://scenes/main_game/field/field.tscn")

@onready var _container: Node2D = %Container

func update_with_number_of_fields(number_of_fields:int) -> void:
	Util.remove_all_children(_container)
	for i in range(number_of_fields):
		var field:Field = FIELD_SCENE.instantiate()
		_container.add_child(field)
	_layout_fields()

func _layout_fields() -> void:
	var fields = _container.get_children()
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
	print("start_x: ", start_x)
	print("total_width: ", total_width)
	print("available_width: ", available_width)
	print("total_fields_width: ", total_fields_width)
	print("spacing: ", spacing)
	
	var current_x = start_x
	for field in fields:
		field.position.x = current_x
		field.position.y = 0
		current_x += field_width + spacing
	return
