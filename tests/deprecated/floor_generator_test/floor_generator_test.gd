extends Node2D

const FLOOR_ICON = preload("res://scenes/GUI/map/map_icon.tscn")
const ICON_DISTANCE := 1

@onready var button: Button = %Button
var floorplan_genenrator:FloorplanGenerator = FloorplanGenerator.new(5, 1)
@onready var container: Control = %Container
var _starting_room_positon:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	container.custom_minimum_size = Vector2(FloorPlanData.MAX_X, FloorPlanData.MAX_Y) * Map.FLOOR_ICON_SIZE
	button.button_up.connect(_on_button_released)
	var starting_room_id = FloorPlanData.STARTING_ROOM
	_starting_room_positon = Vector2(starting_room_id%10, starting_room_id/10) * Map.FLOOR_ICON_SIZE

func _on_button_released():
	Util.remove_all_children(container)
	floorplan_genenrator.generate()
	for room_data in floorplan_genenrator.rooms.values():
		_draw_room(room_data)

func _draw_room(room_data:RoomData):
	var floor_icon = FLOOR_ICON.instantiate()
	room_data.visited = true
	floor_icon.room = room_data
	floor_icon.position = _get_cell_position(room_data, Map.FLOOR_ICON_SIZE)
	container.add_child(floor_icon)

func _get_cell_position(room_data:RoomData, cell_size:int) -> Vector2:
	var starting_room_id = FloorPlanData.STARTING_ROOM
	return room_data.distance_to_origin() * (cell_size +ICON_DISTANCE) + _starting_room_positon
