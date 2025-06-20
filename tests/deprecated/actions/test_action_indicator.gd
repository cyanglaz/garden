extends GutTest

const ROOM_PARAMS := preload("res://tests/fixtures/unit_test_room_params.tres")
const ROOM_SCENE := preload("res://tests/fixtures/unit_test_room.tscn")
const PUSH_DATA := preload("res://tests/fixtures/unit_test_push_action_data.tres")
const CHARACTER_DATA := preload("res://tests/fixtures/unit_test_mob_data.tres")

var room:Room
var character:Character

func before_each():
	var room_data = RoomData.new()
	room_data.setup(ROOM_PARAMS)
	room = autofree(ROOM_SCENE.instantiate())
	room.room_data = room_data
	add_child(room)
	room.prepare()
	character = autofree(CHARACTER_DATA.get_unit_node())
	room.object_container._add_object(character)

func test_push_indicator() -> void:
	var push_indicator:CharacterPushIndicator = autofree(load("res://scenes/combat/combat_indicators/action_indicators/character_push_indicator.tscn").instantiate())
	add_child(push_indicator)
	var push_data := PUSH_DATA.get_duplicate()
	push_data.distance = 3
	push_data.direction_relative_to_owner = true
	var push_action := Util.create_action(0, [0, 0], push_data, 402, 1, true, false)
	push_action.owner_character = character
	push_action.action_handle.collision_tile_id = 405
	push_action.action_handle.landing_tile_id = 404
	push_action.action_handle.has_collision = true
	push_action.action_handle.will_push_target = true
	push_action.watching_tiles = [403]
	push_action.room = room
	push_indicator.update_push(room, push_action)
	var angle := room.get_tile_position(403).direction_to(room.get_tile_position(push_action.action_handle.collision_tile_id)).angle()
	assert_true(push_indicator._canvas_group.visible)
	assert_almost_eq(push_indicator.line_2d.get_point_position(0) + push_indicator.line_2d.global_position, room.get_tile_position(403) + CharacterPushIndicator.OFFSET.rotated(angle), Vector2(0.01, 0.01))
	assert_almost_eq(push_indicator.line_2d.get_point_position(1) + push_indicator.line_2d.global_position, room.get_tile_position(push_action.action_handle.collision_tile_id) - CharacterPushIndicator.OFFSET.rotated(angle), Vector2(0.01, 0.01))
	assert_almost_eq(push_indicator.collision_indicator.global_position, room.get_tile_position(push_action.action_handle.collision_tile_id), Vector2(0.01, 0.01))
	
	push_indicator.indicator_state = CombatIndicator.IndicatorState.NORMAL
	assert_true(push_indicator._canvas_group.visible)
	assert_almost_eq(push_indicator.arrow.scale, CharacterPushIndicator.NORMAL_ARROW_SCALE, Vector2(0.01, 0.01))
	assert_eq(push_indicator.line_2d.width, 3)
	assert_eq(push_indicator._canvas_group.modulate, push_indicator.index_color)
	
	push_action.action_handle.has_collision = false
	push_indicator.indicator_state = CombatIndicator.IndicatorState.HIGHLIGHTED
	push_indicator.update_push(room, push_action)
	assert_true(push_indicator._canvas_group.visible)
	assert_false(push_indicator.collision_indicator.visible)
	assert_almost_eq(push_indicator.arrow.scale, CharacterPushIndicator.HIGHLIGHTED_ARROW_SCALE, Vector2(0.01, 0.01))
	assert_eq(push_indicator.line_2d.width, 4)
	assert_eq(push_indicator._canvas_group.modulate, push_indicator.index_color)
	
	push_action.action_handle.will_push_target = false
	push_indicator.update_push(room, push_action)
	assert_eq(push_indicator._canvas_group.modulate, push_indicator.no_push_color)
