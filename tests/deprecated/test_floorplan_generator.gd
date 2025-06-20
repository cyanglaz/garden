extends GutTest
#
#func test_generate_floors():
	#for i in 500:
		#var floorplan_generator = FloorplanGenerator.new(randi_range(1, 5), 1)
		#floorplan_generator.generate()
		#assert_true(floorplan_generator.room_ids.size() <= (floorplan_generator._flootplan_data.number_of_rooms + 1)) # + 1 for secret room
		#assert_true(floorplan_generator.room_ids.size() >= floorplan_generator._flootplan_data.get_min_rooms())
		#for room_data in floorplan_generator.rooms.values():
			## All rooms have at least one neighbour
			#var neighbours = room_data.get_neighbours()
			#var has_neighbour := false
			#for neighbour in neighbours:
				#if floorplan_generator.room_ids.has(neighbour):
					#has_neighbour = true
					#break
			#assert_true(has_neighbour)
