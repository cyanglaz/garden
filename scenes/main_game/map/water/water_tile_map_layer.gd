class_name WaterTileMapLayer
extends TileMapLayer

const TILESET_SOURCE_ID := 0
const WATER_TILE_COLUMN_INDEX := 0

const WATER_TILE_WEIGHTS := {
	0:100,
	#1:2,
	#2:2,
	#3:2,
	#4:2,
	#5:2,
}

func _ready() -> void:
	_generate_water_tiles()

func _generate_water_tiles() -> void:
	# Adding 2 to the size to ensure it is big enough to cover the viewport
	var tile_map_size := Vector2i(get_viewport_rect().size / rendering_quadrant_size) + Vector2i(2, 2)
	var tile_rect := Rect2i(-tile_map_size / 2, tile_map_size / 2)
	var tile_positions := []
	for x in range(tile_rect.position.x, tile_rect.size.x):
		for y in range(tile_rect.position.y, tile_rect.size.y):
			tile_positions.append(Vector2i(x, y))
	for tile_position in tile_positions:
		var tile_row_index:int = Util.weighted_roll(WATER_TILE_WEIGHTS.keys(), WATER_TILE_WEIGHTS.values())
		set_cell(tile_position, TILESET_SOURCE_ID, Vector2i(WATER_TILE_COLUMN_INDEX, tile_row_index))
