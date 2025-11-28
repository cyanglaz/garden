class_name FieldLand
extends Node2D

const TILE_SET_ID := 0
const TILE_LEFT_X := 0
const TILE_RIGHT_X := 1
const TILE_MIDDLE_X := 2
const CELL_SIZE := Vector2(18, 18)

@onready var tile_map_layer: TileMapLayer = %TileMapLayer
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

var size:int: set = _set_size

func _ready() -> void:
	_set_size(1)

func _set_size(val:int) -> void:
	size = val
	_update_tiles()

func _update_tiles() -> void:
	tile_map_layer.clear()
	tile_map_layer.set_cell(Vector2i(0, 0), TILE_SET_ID, Vector2i(TILE_LEFT_X, 0))
	for i in size:
		tile_map_layer.set_cell(Vector2i(i + 1, 0), TILE_SET_ID, Vector2i(TILE_MIDDLE_X, 0))
	tile_map_layer.set_cell(Vector2i(size + 1, 0), TILE_SET_ID, Vector2i(TILE_RIGHT_X, 0))
	tile_map_layer.position.x = - (size+2)*CELL_SIZE.x/2
	(collision_shape_2d.shape as RectangleShape2D).size.x = CELL_SIZE.x * (size + 2)
	
