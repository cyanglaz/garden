extends GutTest

const ROOM_PARAMS := preload("res://tests/fixtures/unit_test_room_params.tres")
const GAME_SESSION_PRAFAB := preload("res://tests/fixtures/unit_test_game_session.tscn")
const TEST_ROOM_SCENE_SCENE := preload("res://tests/fixtures/unit_test_room_scene.tscn")

var _room_scene: RoomScene
var _room_data:RoomData

func before_each() -> void:
	# Mock game session singleton with level info
	var game_session = autofree(GAME_SESSION_PRAFAB.instantiate())
	Singletons.game_session = game_session
	
	_room_scene = autoqfree(TEST_ROOM_SCENE_SCENE.instantiate())
	_room_scene.level_info = LevelInfo.new()
	_room_data = RoomData.new()
	_room_data.setup(ROOM_PARAMS)
	add_child(_room_scene)

func after_each() -> void:
	Singletons.game_session = null

func test_enter_scene_sets_up_correctly() -> void:
	# Create a real RoomScene using our test class
	await _room_scene.enter_scene(_room_data, CardInventory.new(), ItemInventory.new())
	assert_true(_room_scene._scene_started)

func test_restore_scene_restores_state() -> void:
	var mock_scene_data = {"energy": {"value":3, "max_value":3, "estimate_value":3}}
	await _room_scene.enter_scene(_room_data, CardInventory.new(), ItemInventory.new())
	_room_scene.restore_scene(_room_data, mock_scene_data, CardInventory.new(), ItemInventory.new())
	
	assert_true(_room_scene._scene_started)

func test_player_control_semaphore_lock() -> void:
	# First initialize the scene with some mock data
	await _room_scene.enter_scene(_room_data, CardInventory.new(), ItemInventory.new())
	
	watch_signals(_room_scene.room)
	
	_room_scene._on_request_toggle_lock(true)
	assert_true(_room_scene._player_control_semaphore.locked)
	
	_room_scene._on_request_toggle_lock(false)
	assert_false(_room_scene._player_control_semaphore.locked)
