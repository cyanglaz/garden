extends GutTest

#const ROOM_PARAMS := preload("res://tests/fixtures/unit_test_room_params.tres")
#const ROOM_SCENE := preload("res://tests/fixtures/unit_test_room.tscn")
#const ACTION_DATA := preload("res://tests/fixtures/unit_test_single_target_action_data.tres")
#const CHARACTER_DATA := preload("res://tests/fixtures/unit_test_mob_data.tres")
#const PLAYER_DATA := preload("res://tests/fixtures/unit_test_player_data.tres")
#
#var action_emitter:ActionEmitter
#var room:Room
#var player:Character
#var mob:Character
#
#func before_each():
	#var room_data = RoomData.new()
	#room_data.setup(ROOM_PARAMS)
	#room_data.populate_for_next_wave(0, 1)
	#room = autofree(ROOM_SCENE.instantiate())
	#room.room_data = room_data
	#add_child(room)
	#room.prepare()
	#var player_data := PLAYER_DATA.get_duplicate()
	#player_data.action_datas = [ACTION_DATA.get_duplicate()]
	#player_data.tile_id = 303
	#player = autofree(player_data.get_unit_node())
	#room.object_container.add_player(player)
	#var mob_data := CHARACTER_DATA.get_duplicate()
	#mob_data.tile_id = 304
	#mob_data.action_datas = [ACTION_DATA.get_duplicate()]
	#mob = autofree(mob_data.get_unit_node())
	#room.object_container._add_object(mob)
	#action_emitter = player.action_emitter
	#
#func test_highlight_on_mouse_hover() -> void:
	## Hover player
	#var mouse_cell:MetaTile = room.main_tile_map.meta_tiles[player.tile_id]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#
	## Hover mob
	#mouse_cell = room.main_tile_map.meta_tiles[mob.tile_id]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#
	## Unhover everything
	#mouse_cell = room.main_tile_map.meta_tiles[404]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
#
#func test_click_character() -> void:
	## Click player
	#var mouse_cell:MetaTile = room.main_tile_map.meta_tiles[player.tile_id]
	#room._combat_controller._handle_select(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#
	## hover mob
	#mouse_cell = room.main_tile_map.meta_tiles[mob.tile_id]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#
	## unhover mob
	#mouse_cell = room.main_tile_map.meta_tiles[404]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
#
	## click empty
	#mouse_cell = room.main_tile_map.meta_tiles[404]
	#room._combat_controller._handle_select(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#
	## click mob
	#mouse_cell = room.main_tile_map.meta_tiles[mob.tile_id]
	#room._combat_controller._handle_select(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#
#func test_highlight_when_player_is_in_attack_mode() -> void:
	#player.character_data.turn_state = CharacterData.TurnState.WALKED
	## click player 
	#var mouse_cell:MetaTile = room.main_tile_map.meta_tiles[player.tile_id]
	#room._combat_controller._handle_select(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#
	## hover then create action on it
	#mouse_cell = room.main_tile_map.meta_tiles[mob.tile_id]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#assert_true(player.action_emitter.has_pending_action())
	#
	## create action not targeting mob then hover mob
	#mouse_cell = room.main_tile_map.meta_tiles[203]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#assert_true(player.action_emitter.has_pending_action())
	#
	## hover mob before creating action
	#player.action_emitter.clear_pending_actions()
	#player.character_data.turn_state = CharacterData.TurnState.START
	#mouse_cell = room.main_tile_map.meta_tiles[mob.tile_id]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#player.character_data.turn_state = CharacterData.TurnState.WALKED
	#mouse_cell = room.main_tile_map.meta_tiles[player.tile_id]
	#room._combat_controller._handle_select(mouse_cell)
	#mouse_cell = room.main_tile_map.meta_tiles[mob.tile_id]
	#room.main_tile_map.mouse_cell_updated.emit(mouse_cell)
	#assert_eq(player.indicator_state, CombatIndicator.IndicatorState.HIGHLIGHTED)
	#assert_eq(mob.indicator_state, CombatIndicator.IndicatorState.MINIMUM)
	#assert_true(player.action_emitter.has_pending_action())
