extends GutTest

var ROOM_PARAMS := load("res://tests/fixtures/unit_test_room_params.tres")
const ROOM_SCENE := preload("res://tests/fixtures/unit_test_room.tscn")
const ACTION_DATA := preload("res://tests/fixtures/unit_test_single_target_action_data.tres")
const CHARACTER_DATA := preload("res://tests/fixtures/unit_test_mob_data.tres")
const PUSH_ACTION_DATA := preload("res://tests/fixtures/unit_test_push_action_data.tres")

var action_emitter:ActionEmitter
var room:Room
var emitting_character:Character
var target_character:Character

func before_each():
	ROOM_PARAMS.map_width = 9
	ROOM_PARAMS.map_height = 9
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
	var emitting_character_data := CHARACTER_DATA.get_duplicate()
	emitting_character_data.tile_id = 303
	emitting_character_data.action_datas = [ACTION_DATA.get_duplicate()]
	emitting_character = autofree(emitting_character_data.get_duplicate().get_unit_node())
	var target_character_data = CHARACTER_DATA.get_duplicate()
	target_character_data.tile_id = 202
	target_character = autofree(target_character_data.get_unit_node())
	room.object_container._add_object(emitting_character)
	room.object_container._add_object(target_character)
	action_emitter = emitting_character.action_emitter
	
func test_action_emitter_create_action_on_valid_tile() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	action_strategy.action_data = action_data
	emitting_character.tile_id = 404
	action_strategy.setup(action_data, 406, 404, [0], false)
	action_emitter.create_actions(action_strategy)
	assert_eq(action_emitter.pending_actions.size(), 1)

	#Evaluate actions
	var action:Action = action_emitter.pending_actions.front()
	assert_eq((action.action_handle as AttackHandle).damage, 1)
	assert_eq(action.target_tile.tile_id, action_strategy.main_target_absolute_tile_id)

	#Deploy actions
	action_emitter.deploy_pending_actions()
	#assert_eq(action_emitter.pending_actions.size(), 0)

func test_attack_evaluate_on_create_if_character_selected() -> void:
	emitting_character.selected = true
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	action_strategy.action_data = action_data
	emitting_character.tile_id = 404
	action_strategy.setup(action_data, 404, 404, [0], false)
	action_emitter.create_actions(action_strategy)
	assert_eq(action_emitter.pending_actions.size(), 1)
	
	var action:Action = action_emitter.pending_actions.front()
	assert_eq((action.action_handle as AttackHandle).damage, 1)

func test_action_emitter_directional_hitting_target() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	action_data.deploy_type = ActionData.DeployType.DIRECTIONAL
	action_strategy.action_data = action_data
	emitting_character.tile_id = 404
	target_character.tile_id = 405
	action_strategy.setup(action_data, 405, 404, [0], false)
	action_strategy.moves = [0]
	action_emitter.create_actions(action_strategy)
	assert_eq(action_emitter.pending_actions.size(), 1)
	var action:Action = action_emitter.pending_actions.front()

	#Evaluate actions
	action_emitter.evaluate_pending_actions()
	assert_eq((action.action_handle as AttackHandle).damage, 1)
	assert_eq(action.target_tile.tile_id, target_character.tile_id)
	assert_eq(action.target_unit, target_character)
	
	#Exmaine Indicator
	await wait_frames(1)
	ActionTestsUtils.test_directional_indicator(self, action, action_emitter, room)
	
	# Target Character Moved
	target_character.tile_id = 303
	assert_eq(action.target_tile.tile_id, 404 + action_data.deploy_range.y)
	assert_null(action.target_unit)
	await wait_frames(1)
	ActionTestsUtils.test_directional_indicator(self, action, action_emitter, room)

func test_action_emitter_create_action_on_invalid_tile() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	action_strategy.action_data = action_data
	emitting_character.tile_id = 404
	action_strategy.setup(action_data, 409, 404, [0], false)
	action_emitter.create_actions(action_strategy)
	assert_eq(action_emitter.pending_actions.size(), 0)

func test_action_emitter_moved_target_tile_outside_map() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	action_strategy.action_data = action_data
	emitting_character.tile_id = 505
	action_strategy.setup(action_data, 506, 505, [0], false)
	action_emitter.create_actions(action_strategy)

	#Evaluate actions
	var action:Action = action_emitter.pending_actions.front()
	assert_eq(action.target_tile_id, 506)
	#Move
	assert(!room.room_data.arena.has_discovered_tile(508))
	assert(room.room_data.arena.has_discovered_tile(507))
	emitting_character.tile_id = 507
	
	#action_emitter.evaluate_pending_actions()
	assert_eq(action.emitting_from_position_id, 507)
	assert_eq(action.target_tile_id, 508)
	assert_eq((action.action_handle as AttackHandle).damage, 1)

func test_action_emitter_directional_moved_target_tile_outside_map() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	action_data.deploy_type = ActionData.DeployType.DIRECTIONAL
	action_strategy.action_data = action_data
	emitting_character.tile_id = 504
	action_strategy.setup(action_data, 505, 504, [0], false)
	action_emitter.create_actions(action_strategy)

	#Evaluate actions
	var action:Action = action_emitter.pending_actions.front()
	assert_eq(action.target_tile_id, 507)
	await wait_frames(1)
	ActionTestsUtils.test_directional_indicator(self, action, action_emitter, room)
	
	#Move
	assert(!room.room_data.arena.has_discovered_tile(508))
	assert(room.room_data.arena.has_discovered_tile(507))
	emitting_character.tile_id = 507
	
	#action_emitter.evaluate_pending_actions()
	assert_eq(action.emitting_from_position_id, 507)
	assert_eq(action.target_tile_id, 508)
	assert_eq((action.action_handle as AttackHandle).damage, 1)
	await wait_frames(1)
	ActionTestsUtils.test_directional_indicator(self, action, action_emitter, room)

func test_push() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := PUSH_ACTION_DATA.get_duplicate()
	action_data.distance = 1
	action_data.direction_relative_to_owner = true
	action_strategy.action_data = action_data
	emitting_character.tile_id = 404
	action_strategy.setup(action_data, 406, 404, [0], false)
	action_emitter.create_actions(action_strategy)
	
	assert_eq(action_emitter.pending_actions.size(), 1)
	var push_action:Action = action_emitter.pending_actions.front()
	action_emitter.evaluate_pending_actions()
	var handle := push_action.action_handle as PushHandle
	assert_eq(push_action.emitting_from_position_id, 404)
	assert_eq(push_action.target_tile_id, 406)
	assert_false(handle.has_collision)
	assert_false(handle.will_push_target)
	assert_eq(handle.landing_tile_id, 407)
	await wait_frames(1)
	ActionTestsUtils.test_push_indicator(self, push_action, action_emitter, room)

func test_push_no_target() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := PUSH_ACTION_DATA.get_duplicate()
	action_data.distance = 1
	action_strategy.action_data = action_data
	action_data.direction_relative_to_owner = true
	emitting_character.tile_id = 204
	action_strategy.setup(action_data, 305, 405, [0], false)
	action_emitter.create_actions(action_strategy)
	
	assert_eq(action_emitter.pending_actions.size(), 1)
	action_emitter.evaluate_pending_actions()
	var push_action:Action = action_emitter.pending_actions.front()
	var handle := push_action.action_handle as PushHandle
	assert_eq(push_action.emitting_from_position_id, 405)
	assert_eq(push_action.target_tile_id, 305)
	assert_null(push_action.target_unit)
	assert_false(handle.has_collision)
	assert_false(handle.will_push_target)
	assert_eq(handle.landing_tile_id, 205)
	await wait_frames(1)
	ActionTestsUtils.test_push_indicator(self, push_action, action_emitter, room)

func test_push_after_moved_landing_tile_outside_map() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	var push_data := PUSH_ACTION_DATA.get_duplicate()
	push_data.distance = 1
	push_data.direction_relative_to_owner = true
	action_data.next_actions = [push_data]
	action_strategy.action_data = action_data
	emitting_character.tile_id = 404
	action_strategy.setup(action_data, 406, 404, [0], false)
	action_emitter.create_actions(action_strategy)

	#Evaluate actions
	var action:Action = action_emitter.pending_actions.front()
	#Move
	assert(!room.room_data.arena.has_discovered_tile(409))
	assert(room.room_data.arena.has_discovered_tile(408))
	emitting_character.tile_id = 406
	
	action_emitter.evaluate_pending_actions()
	assert_true(action.next.is_empty())
#
# This test is only relative if we also telegraphing moves.
#func test_directional_attack_not_blocked_by_self() -> void:
	#var action_strategy := ActionStrategy.new()
	#var action_data := ACTION_DATA.get_duplicate()
	#action_data.deploy_type = ActionData.DeployType.DIRECTIONAL
	#action_strategy.action_data = action_data
	#emitting_character.tile_id = 404
	#action_strategy.setup(action_data, 403, 405, [0], false)
	#action_emitter.create_actions(action_strategy)
	#
	#assert_eq(action_emitter.pending_actions.size(), 1)
	#var action:Action = action_emitter.pending_actions.front()
	#action_emitter.evaluate_pending_actions()
	#
	## Assert the attack is not blocked by owner character
	#assert_eq(action.emitting_from_position_id, 405)
	#assert_eq(action.target_tile_id, 402)
	#assert_eq(action.watching_tiles.size(), 3)
	#assert_eq(action.watching_tiles[0], 404)
	#assert_eq(action.watching_tiles[1], 403)
	#assert_eq(action.watching_tiles[2], 402)
	#await wait_frames(1)
	#ActionTestsUtils.test_directional_indicator(self, action, action_emitter, room)

func test_action_target_tile_indicator_and_damage_label() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	var push_data := PUSH_ACTION_DATA.get_duplicate()
	push_data.distance = 1
	push_data.direction_relative_to_owner = true
	action_data.next_actions = [push_data]
	action_strategy.action_data = action_data
	emitting_character.tile_id = 404
	action_strategy.setup(action_data, 404, 404, [0], false)
	action_emitter.create_actions(action_strategy)
	
	# Show damage label and sprite
	emitting_character.selected = true
	action_emitter.indicator_state = CombatIndicator.IndicatorState.HIGHLIGHTED
	action_emitter.evaluate_pending_actions()
	var attack:Action = action_emitter.pending_actions.front()
	await wait_frames(1)
	ActionTestsUtils.test_action_target_indicator(self, attack, action_emitter)

	# sprite without damage label
	emitting_character.selected = false
	action_emitter.indicator_state = CombatIndicator.IndicatorState.NORMAL
	action_emitter.evaluate_pending_actions()
	await wait_frames(1)
	ActionTestsUtils.test_action_target_indicator(self, attack, action_emitter)

	# no sprite no damage label
	emitting_character.selected = false
	action_emitter.indicator_state = CombatIndicator.IndicatorState.NORMAL
	action_emitter.evaluate_pending_actions()
	await wait_frames(1)
	ActionTestsUtils.test_action_target_indicator(self, attack, action_emitter)
	
func test_artillery_action_indicator() -> void:
	var action_strategy := ActionStrategy.new()
	var action_data := ACTION_DATA.get_duplicate()
	action_data.deploy_type = ActionData.DeployType.ARTILLERY
	action_strategy.action_data = action_data
	emitting_character.tile_id = 505
	action_strategy.setup(action_data, 507, 505, [0], false)
	action_emitter.create_actions(action_strategy)
	
	assert_eq(action_emitter.action_indicator_container.map.size(), 1)
	var action:Action = action_emitter.pending_actions.front()
	ActionTestsUtils.test_artillery_action_indicator(self, action, action_emitter)
