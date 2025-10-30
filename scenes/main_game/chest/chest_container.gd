class_name ChestContainer
extends Node2D

signal chest_selected(index:int)

const MAX_DISTANCE_BETWEEN_CHESTS := 15
const MARGIN := 36

const CHEST_SCENE := preload("res://scenes/main_game/chest/chest.tscn")

@onready var container: Node2D = %Container

func _ready() -> void:
	update_with_number_of_chests(3)

func update_with_number_of_chests(number_of_chests:int) -> void:
	Util.remove_all_children(container)
	for i in range(number_of_chests):
		var chest:Chest = CHEST_SCENE.instantiate()
		chest.selected.connect(_on_chest_selected.bind(i))
		container.add_child(chest)
	_layout_chests()

func get_chest(index:int) -> Chest:
	return container.get_child(index)
	
func _layout_chests() -> void:
	if container.get_child_count() == 0:
		return
	# Get screen size
	var screen_size = get_viewport().get_visible_rect().size
	
	# Calculate total width needed for all fields
	var total_chests_width = 0.0
	var chest_width:float = container.get_child(0).gui_basic_button.size.x
	for chest:Chest in container.get_children():
		total_chests_width += chest_width
	
		# Calculate spacing between fields
	var available_width = screen_size.x - MARGIN * 2  # Leave 20px margin on each side
	var spacing = 0.0
	
	if container.get_child_count() > 1:
		var total_spacing_needed = available_width - total_chests_width
		spacing = min(total_spacing_needed / (container.get_child_count() - 1), MAX_DISTANCE_BETWEEN_CHESTS)
	var total_width = total_chests_width + (spacing * (container.get_child_count() - 1))
	
	var start_x = - total_width / 2 + chest_width/2
	
	var current_x = start_x
	for chest in container.get_children():
		chest.position.x = current_x
		chest.position.y = 0
		current_x += chest_width + spacing
	return


func _on_chest_selected(index:int) -> void:
	for child:Chest in container.get_children():
		child.disabled = true
	chest_selected.emit(index)
