extends GutTest

var ROOM_PARAMS := preload("res://tests/fixtures/unit_test_room_params.tres")
const ROOM_SCENE := preload("res://tests/fixtures/unit_test_room.tscn")
const ACTION_DATA := preload("res://tests/fixtures/unit_test_single_target_action_data.tres")
const MOB_DATA := preload("res://tests/fixtures/unit_test_mob_data.tres")
const PLAYER_DATA := preload("res://tests/fixtures/unit_test_player_data.tres")

var room:Room
var player:Player
var mob1:Mob
var mob2:Mob

var _default_telegraph_moves:bool = Constants.TELEGRAPHING_MOVES

func before_each():
	Constants.TELEGRAPHING_MOVES = true
	ROOM_PARAMS.max_number_of_water = 0
	var room_data = RoomData.new()
	room_data.setup(ROOM_PARAMS)
	room = autofree(ROOM_SCENE.instantiate())
	room.room_data = room_data
	add_child(room)
	room.prepare()
	# Remove traveler for the test
	room.player_squad.player.tile_id = -1
	var action_data:ActionData = ACTION_DATA.get_duplicate()
	action_data.deploy_type = ActionData.DeployType.DIRECTIONAL
	var player_data = PLAYER_DATA.get_duplicate()
	player_data.action_datas.append(action_data.get_duplicate())
	player = autofree(player_data.get_duplicate().get_unit_node())
	var mob1_data = MOB_DATA.get_duplicate()
	mob1_data.action_datas.append(action_data.get_duplicate())
	mob1 = autofree(mob1_data.get_duplicate().get_unit_node())
	var mob2_data = MOB_DATA.get_duplicate()
	mob2_data.action_datas.append(action_data.get_duplicate())
	mob2 = autofree(mob2_data.get_duplicate().get_unit_node())
	room.object_container._add_object(player)
	room.object_container._add_object(mob1)
	room.object_container._add_object(mob2)
	mob1.order_index = 1
	mob2.order_index = 2
	for tile_meta_data:TileMetaData in room.room_data.arena.map.values():
		assert(tile_meta_data.is_movable_with_index(Constants.DEFAULT_ORDER_INDEX))

func after_each() -> void:
	Constants.TELEGRAPHING_MOVES = _default_telegraph_moves

func test_earlier_mob_intends_to_block_later_mob() -> void:
	mob1.tile_id = 104
	mob2.tile_id = 303
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	mob2.move_emitter.setup_with_ordered_moves([0, -100])
	assert(mob1.move_emitter.pending_moves.size() == 2)
	assert_eq(mob1.move_emitter.pending_moves.size(), 2)
	assert_eq(mob2.move_emitter.pending_moves.size(), 1)

func test_earlier_mob_intends_to_block_later_mob_after_later_mob_has_set_up_moves() -> void:
	mob1.tile_id = 104
	mob2.tile_id = 303
	mob2.move_emitter.setup_with_ordered_moves([0, -100])
	assert_eq(mob2.move_emitter.pending_moves.size(), 2)
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	assert_eq(mob1.move_emitter.pending_moves.size(), 2)
	assert_eq(mob2.move_emitter.pending_moves.size(), 1)

func test_earlier_mob_moves_out_of_later_mobs_path() -> void:
	mob1.tile_id = 104
	mob2.tile_id = 303
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	mob2.move_emitter.setup_with_ordered_moves([0, -100])
	assert_eq(mob2.move_emitter.pending_moves.size(), 1)
	mob1.tile_id -= 1
	assert_eq(mob2.move_emitter.pending_moves.size(), 2)

func test_later_mob_current_position_block_earlier_mob() -> void:
	mob1.tile_id = 104
	mob2.tile_id = 203
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	mob2.move_emitter.setup_with_ordered_moves([0, -100])
	assert_eq(mob1.move_emitter.pending_moves.size(), 1)
	assert_eq(mob2.move_emitter.pending_moves.size(), 2)

func test_earlier_mob_moves_into_later_mobs_path_does_not_block_later_mob() -> void:
	mob1.tile_id = 303
	mob2.tile_id = 403
	mob1.move_emitter.setup_with_ordered_moves([0, -1])
	mob2.move_emitter.setup_with_ordered_moves([0, -1])
	assert_eq(mob1.move_emitter.pending_moves.size(), 2)
	assert_eq(mob2.move_emitter.pending_moves.size(), 2)
	mob1.tile_id = mob2.destination_tile_id
	assert_eq(mob2.move_emitter.pending_moves.size(), 2)

func test_later_mob_moves_into_earlier_mobs_path_after_earlier_mob_has_set_up_moves() -> void:
	mob1.tile_id = 104
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	assert_eq(mob1.move_emitter.pending_moves.size(), 2)
	mob2.tile_id = 203
	assert_eq(mob1.move_emitter.pending_moves.size(), 1)

func test_later_mob_moves_out_earlier_mobs_path() -> void:
	mob1.tile_id = 104
	mob2.tile_id = 203
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	assert_eq(mob1.move_emitter.pending_moves.size(), 1)
	mob2.tile_id += 1
	assert_eq(mob1.move_emitter.pending_moves.size(), 2)

func test_later_mobs_intends_to_move_into_earlier_mobs_path_does_not_block_earlier_mob() -> void:
	mob1.tile_id = 303
	mob2.tile_id = 305
	mob1.move_emitter.setup_with_ordered_moves([0, 1])
	mob2.move_emitter.setup_with_ordered_moves([0, -1])
	assert_eq(mob1.move_emitter.pending_moves.size(), 2)
	assert_eq(mob2.move_emitter.pending_moves.size(), 1)	

func test_player_moves_into_mobs_path() -> void:
	mob1.tile_id = 104
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	player.tile_id = 203
	assert_eq(mob1.move_emitter.pending_moves.size(), 1)

func test_player_moves_out_mobs_path() -> void:
	mob1.tile_id = 104
	player.tile_id = 203
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	assert_eq(mob1.move_emitter.pending_moves.size(), 1)
	player.tile_id = 204
	assert_eq(mob1.move_emitter.pending_moves.size(), 2)

func test_player_intend_does_not_block_mobs() -> void:
	mob1.tile_id = 505
	mob1.move_emitter.setup_with_ordered_moves([0, -1])
	player.tile_id = 503
	player.move_emitter.setup_with_ordered_moves([0, 1])
	assert_eq(mob1.move_emitter.pending_moves.size(), 2)

func test_mobs_blocking_each_other() -> void:
	mob1.tile_id = 104
	mob2.tile_id = 203
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	mob2.move_emitter.setup_with_ordered_moves([0, -99])
	assert_eq(mob1.move_emitter.pending_moves.size(), 1)
	assert_eq(mob2.move_emitter.pending_moves.size(), 1)

func test_earlier_mob_plans_to_move_into_later_mobs_action_path() -> void:
	mob1.tile_id = 404
	mob2.tile_id = 505
	var mob_2_strategy := ActionStrategy.new()
	mob_2_strategy.setup(mob1.character_data.action_datas.front().get_duplicate(), 503, 505, [0, -1], false)
	mob2.move_emitter.create_moves(mob_2_strategy)
	mob2.action_emitter.create_actions(mob_2_strategy)
	assert(mob2.action_emitter.pending_actions.size() == 1)
	var action:Action = mob2.action_emitter.pending_actions[0]
	assert(action.watching_tiles.has(503))
	assert_eq(action.target_tile_id, 501)
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob2.action_emitter, room)
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	await get_tree().process_frame
	assert_eq(action.target_tile_id, 503)
	ActionTestsUtils.test_directional_indicator(self, action, mob2.action_emitter, room)

func test_earlier_mob_plans_to_move_out_later_mobs_action_path_with_push_attack() -> void:	
	mob1.tile_id = 404
	mob2.tile_id = 505
	var mob_2_strategy := ActionStrategy.new()
	mob_2_strategy.setup(mob1.character_data.action_datas.front().get_duplicate(), 503, 505, [0, -1], false)
	mob1.move_emitter.setup_with_ordered_moves([0, 99])
	mob2.move_emitter.create_moves(mob_2_strategy)
	mob2.action_emitter.create_actions(mob_2_strategy)
	assert(mob2.action_emitter.pending_actions.size() == 1)
	var action:Action = mob2.action_emitter.pending_actions[0]
	assert(action.watching_tiles.has(503))
	assert_eq(action.target_tile_id, 503)
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob2.action_emitter, room)
	mob1.tile_id = 400
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob2.action_emitter, room)
	assert_eq(action.target_tile_id, 501)

func test_player_moves_into_mobs_action_path() -> void:
	player.tile_id = 404
	mob2.tile_id = 505
	var mob_2_strategy := ActionStrategy.new()
	mob_2_strategy.setup(player.character_data.action_datas.front().get_duplicate(), 503, 505, [0, -1], false)
	mob2.move_emitter.create_moves(mob_2_strategy)
	mob2.action_emitter.create_actions(mob_2_strategy)
	assert(mob2.action_emitter.pending_actions.size() == 1)
	var action:Action = mob2.action_emitter.pending_actions[0]
	assert(action.watching_tiles.has(503))
	assert_eq(action.target_tile_id, 501)
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob2.action_emitter, room)
	player.tile_id = 503
	assert_eq(action.target_tile_id, 503)
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob2.action_emitter, room)

func test_player_moves_out_mobs_action_path() -> void:
	player.tile_id = 503
	mob2.tile_id = 505
	var mob_2_strategy := ActionStrategy.new()
	mob_2_strategy.setup(player.character_data.action_datas.front().get_duplicate(), 503, 505, [0, -1], false)
	player.move_emitter.setup_with_ordered_moves([0, 99])
	mob2.move_emitter.create_moves(mob_2_strategy)
	mob2.action_emitter.create_actions(mob_2_strategy)
	assert(mob2.action_emitter.pending_actions.size() == 1)
	var action:Action = mob2.action_emitter.pending_actions[0]
	assert(action.watching_tiles.has(503))
	assert_eq(action.target_tile_id, 503)
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob2.action_emitter, room)
	player.tile_id = 400
	assert_eq(action.target_tile_id, 501)
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob2.action_emitter, room)

func test_later_mob_moves_into_ealier_mobs_action_path() -> void:
	mob1.tile_id = 505
	mob2.tile_id = 403
	var mob_1_strategy := ActionStrategy.new()
	mob_1_strategy.setup(mob1.character_data.action_datas.front().get_duplicate(), 503, 505, [0, -1], false)
	mob1.move_emitter.create_moves(mob_1_strategy)
	mob1.action_emitter.create_actions(mob_1_strategy)
	assert(mob1.action_emitter.pending_actions.size() == 1)
	var action:Action = mob1.action_emitter.pending_actions[0]
	assert(action.watching_tiles.has(503))
	assert_eq(action.target_tile_id, 501)
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob1.action_emitter, room)
	mob2.tile_id = 503
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob1.action_emitter, room)
	assert_eq(action.target_tile_id, 503)


func test_later_mob_moves_out_ealier_mobs_action_path() -> void:
	mob1.tile_id = 505
	mob2.tile_id = 503
	var mob_1_strategy := ActionStrategy.new()
	mob_1_strategy.setup(mob1.character_data.action_datas.front().get_duplicate(), 503, 505, [0, -1], false)
	mob1.move_emitter.create_moves(mob_1_strategy)
	mob1.action_emitter.create_actions(mob_1_strategy)
	assert(mob1.action_emitter.pending_actions.size() == 1)
	var action:Action = mob1.action_emitter.pending_actions[0]
	assert(action.watching_tiles.has(503))
	assert_eq(action.target_tile_id, 503)
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob1.action_emitter, room)
	mob2.tile_id = 400
	await get_tree().process_frame
	ActionTestsUtils.test_directional_indicator(self, action, mob1.action_emitter, room)
	assert_eq(action.target_tile_id, 501)
