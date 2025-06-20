extends GutTest

const ROOM_PARAMS := preload("res://tests/fixtures/unit_test_room_params.tres")
const ROOM_SCENE := preload("res://tests/fixtures/unit_test_room.tscn")
const CHARACTER_DATA := preload("res://tests/fixtures/unit_test_mob_data.tres")

var room:Room
var main_character:Character
var move_emitter:MoveEmitter
var blocking_character:Character

func before_each():
	var room_data = RoomData.new()
	room_data.setup(ROOM_PARAMS)
	room = autofree(ROOM_SCENE.instantiate())
	room.room_data = room_data
	add_child(room)
	room.prepare()
	room.player_squad.player.tile_id = -1
	# room.start()
	#action_emitter = autofree(ActionEmitter.new())
	#action_emitter.room = room
	#add_child(action_emitter)
	var main_character_data := CHARACTER_DATA.get_duplicate()
	main_character_data.tile_id = 303
	main_character = autofree(main_character_data.get_duplicate().get_unit_node())
	var blocking_character_data = CHARACTER_DATA.get_duplicate()
	blocking_character_data.tile_id = 202
	blocking_character = autofree(blocking_character_data.get_unit_node())
	room.object_container._add_object(main_character)
	room.object_container._add_object(blocking_character)
	move_emitter = main_character.move_emitter

func test_create_signal() -> void:
	watch_signals(move_emitter)
	move_emitter.setup_with_ordered_moves([-1, -1])
	assert_signal_emit_count(move_emitter, "moves_created", 1)

func test_create_none_blocked_path() -> void:
	main_character.tile_id = 303
	blocking_character.tile_id = 202
	move_emitter.setup_with_ordered_moves([0, -1, -1])
	assert_eq(move_emitter.pending_moves.size(), 3)
	assert_eq(main_character.destination_tile_id, 301)

func test_create_blocked_path() -> void:
	main_character.tile_id = 303
	blocking_character.tile_id = 202
	move_emitter.setup_with_ordered_moves([0, -100, -1])
	assert_eq(move_emitter.pending_moves.size(), 2)
	assert_eq(main_character.destination_tile_id, 203)

func test_non_block_path_indicator() -> void:
	main_character.tile_id = 303
	main_character.indicator_state = CombatIndicator.IndicatorState.NORMAL
	blocking_character.tile_id = 202
	move_emitter.setup_with_ordered_moves([0, -1, -1])
	var move_indicator:CharacterMovementIndicator = move_emitter.character_movement_indicator
	assert_eq(move_indicator.indicator_state, CombatIndicator.IndicatorState.NORMAL)
	assert_true(move_indicator.line_and_arrow.visible)
	assert_eq(move_indicator.line_2d.get_point_count(), move_emitter.pending_moves.size())
	var tile_id := main_character.tile_id
	for i in move_emitter.pending_moves.size():
		tile_id += move_emitter.pending_moves[i]
		var tile_global_position := room.get_tile_position(tile_id)
		var offset := Vector2.ZERO
		if i == 0 && move_emitter.pending_moves.size() > 1:
			var next_tile:int = tile_id + move_emitter.pending_moves[i+1]
			var second_point_global_position := room.get_tile_position(next_tile)
			var offset_angle := tile_global_position.direction_to(second_point_global_position).angle()
			offset = CharacterMovementIndicator.FIRST_POINT_OFFSET.rotated(offset_angle)
		elif i == move_emitter.pending_moves.size() - 1:
			var previous_tile:int = tile_id - move_emitter.pending_moves[i-1]
		assert_almost_eq(move_indicator.line_2d.get_point_position(i), move_indicator.to_local(tile_global_position + offset), Vector2.ONE * 0.01)
	assert_almost_eq(move_indicator.arrow.global_position, move_indicator.to_global(move_indicator.line_2d.get_point_position(move_emitter.pending_moves.size() -1)), Vector2.ONE * 0.01)
	assert_false(move_indicator.stop.visible)

func test_block_path_indicator() -> void:
	main_character.tile_id = 303
	main_character.indicator_state = CombatIndicator.IndicatorState.NORMAL
	blocking_character.tile_id = 202
	move_emitter.setup_with_ordered_moves([0, -100, -1])
	var move_indicator:CharacterMovementIndicator = move_emitter.character_movement_indicator
	assert_eq(move_indicator.indicator_state, CombatIndicator.IndicatorState.NORMAL)
	assert_true(move_indicator.line_and_arrow.visible)
	assert_true(move_indicator.stop.visible)
	var tile_id := main_character.tile_id
	for i in move_emitter.pending_moves.size():
		tile_id += move_emitter.pending_moves[i]
		var tile_global_position := room.get_tile_position(tile_id)
		var offset := Vector2.ZERO
		if i == 0 && move_emitter.pending_moves.size() > 1:
			var next_tile:int = tile_id + move_emitter.pending_moves[i+1]
			var second_point_global_position := room.get_tile_position(next_tile)
			var offset_angle := tile_global_position.direction_to(second_point_global_position).angle()
			offset = CharacterMovementIndicator.FIRST_POINT_OFFSET.rotated(offset_angle)
		elif i == move_emitter.pending_moves.size() - 1:
			var previous_tile:int = tile_id - move_emitter.pending_moves[i]
		assert_almost_eq(move_indicator.line_2d.get_point_position(i), move_indicator.to_local(tile_global_position + offset), Vector2.ONE * 0.01)
	assert_almost_eq(move_indicator.arrow.global_position, move_indicator.to_global(move_indicator.line_2d.get_point_position(move_emitter.pending_moves.size() -1)), Vector2.ONE * 0.01)
	
	var blocked_tile_id :int = blocking_character.tile_id
	var stopped_tile_global_position := room.get_tile_position(tile_id)
	var blocked_tile_global_position := room.get_tile_position(blocked_tile_id)
	assert_almost_eq(move_indicator.stop.global_position, (stopped_tile_global_position + blocked_tile_global_position)/2, Vector2.ONE * 0.01)

func test_blocked_with_no_moves() -> void:
	main_character.tile_id = 303
	main_character.indicator_state = CombatIndicator.IndicatorState.NORMAL
	blocking_character.tile_id = 203
	move_emitter.setup_with_ordered_moves([0, -100, -1])
	var move_indicator:CharacterMovementIndicator = move_emitter.character_movement_indicator
	assert_eq(move_indicator.indicator_state, CombatIndicator.IndicatorState.NORMAL)
	assert_false(move_indicator.line_and_arrow.visible)
	assert_true(move_indicator.stop.visible)

	var tile_id := main_character.tile_id
	var next_tile_id:int = blocking_character.tile_id
	var stopped_tile_global_position := room.get_tile_position(tile_id)
	var blocked_tile_global_position := room.get_tile_position(next_tile_id)
	assert_almost_eq(move_indicator.stop.global_position, (stopped_tile_global_position + blocked_tile_global_position)/2, Vector2.ONE * 0.01)
