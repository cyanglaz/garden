extends GutTest

var room:Room

func before_each():
	room = autofree(load("res://scenes/game_session/combat_sceneroom.tscn").instantiate())
	var param := RoomParams.new()
	param.level = 1
	var room_data = RoomData.new()
	room_data.setup(param)
	room.room_data = room_data
	add_child(room)
	room.prepare()
	room.enter()

func _test_turns() -> void:
	room.enter()
	room.object_container.level = 10
	room.object_container.level = 1
	room.object_container.spawn_mobs = true
	room.turn_manager.go_next_turn()
	assert_eq(room.turn_manager.id, 1)
	room.turn_manager.end_player_turn()
	assert_eq(room.object_container._mob_manager._mobs_in_turn.size(), room.object_container.get_mobs().size())
	for mob in room.object_container.get_mobs():
		mob.end_turn()
	assert_eq(room.object_container._mob_manager._mobs_in_turn.size(), 0)
	assert_eq(room.turn_manager.id, 2)
