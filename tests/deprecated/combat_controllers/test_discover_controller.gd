# test_discover_controller.gd
extends GutTest

#var ROOM_PARAMS := load("res://tests/fixtures/unit_test_room_params.tres")
#const ROOM_SCENE := preload("res://tests/fixtures/unit_test_room.tscn")

#var controller: DiscoverController
#var room: Room
#
#func test_discover() -> void:
	#for start_distance:int in range(2, 4):	
		#var room_data = RoomData.new()
		#room_data.setup(ROOM_PARAMS)
		#room = autofree(ROOM_SCENE.instantiate())
		#room.room_data = room_data
		#add_child(room)
		#room.prepare()
#
		## Initialize the controller with the Room instance
		#controller = autofree(DiscoverController.new(room))
		#add_child(controller)
		#
		#var corrupted_tiles := room.room_data.arena.get_tiles_with_types([TileMetaData.TileType.CORRUPTED]).filter(func(tile_id:int): return room.room_data.arena.map[tile_id].discovered)
		#var discovered_tiles := room.room_data.arena.get_discovered_tiles()
		#corrupted_tiles.shuffle()
		#var tile_to_discover :int = corrupted_tiles.pop_back()
		#var mouse_cell :MetaTile = room.main_tile_map.meta_tiles[tile_to_discover]
		#controller._handle_select(mouse_cell)
		#await wait_for_signal(controller.discover_finished, 10)
		#var new_total_discovered_tiles := room.room_data.arena.get_discovered_tiles()
		#var discovered_tiles_diff: Array[int] = new_total_discovered_tiles.filter(func(tile_id: int) -> bool: return !discovered_tiles.has(tile_id))
		#for tile_id:int in discovered_tiles_diff:
			## Assert here for quicker failure response.
			#assert(room.room_data.arena.get_distance(room.room_data.arena._center, tile_id) == start_distance + 1)
			#assert_eq(room.room_data.arena.get_distance(room.room_data.arena._center, tile_id), start_distance + 1)
#
#func test_discover_after_reload_save() -> void:
	#for start_distance:int in range(2, 4):	
		#var room_data = RoomData.new()
		#room_data.setup(ROOM_PARAMS)
		#room = autofree(ROOM_SCENE.instantiate())
		#room.room_data = room_data
		#add_child(room)
		#room.prepare()
#
		## Initialize the controller with the Room instance
		#controller = autofree(DiscoverController.new(room))
		#add_child(controller)
		#
		#room.room_data._snapshot.save()
		#room.room_data._snapshot.load_self_save()
		#room.prepare()
		#
		#var corrupted_tiles := room.room_data.arena.get_tiles_with_types([TileMetaData.TileType.CORRUPTED]).filter(func(tile_id:int): return room.room_data.arena.map[tile_id].discovered)
		#var discovered_tiles := room.room_data.arena.get_discovered_tiles()
		#corrupted_tiles.shuffle()
		#var tile_to_discover :int = corrupted_tiles.pop_back()
		#var mouse_cell :MetaTile = room.main_tile_map.meta_tiles[tile_to_discover]
		#controller._handle_select(mouse_cell)
		#await wait_for_signal(controller.discover_finished, 10)
		#var new_total_discovered_tiles := room.room_data.arena.get_discovered_tiles()
		#var discovered_tiles_diff: Array[int] = new_total_discovered_tiles.filter(func(tile_id: int) -> bool: return !discovered_tiles.has(tile_id))
		#for tile_id:int in discovered_tiles_diff:
			## Assert here for quicker failure response.
			#assert(room.room_data.arena.get_distance(room.room_data.arena._center, tile_id) == start_distance + 1)
			#assert_eq(room.room_data.arena.get_distance(room.room_data.arena._center, tile_id), start_distance + 1)
