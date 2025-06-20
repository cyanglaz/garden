# test_card_controller.gd
extends GutTest

const ROOM_PARAMS := preload("res://tests/fixtures/unit_test_room_params.tres")
const ROOM_SCENE := preload("res://tests/fixtures/unit_test_room.tscn")
const CARD_DATA := preload("res://tests/fixtures/unit_test_card_data.tres")

class MockMetaTile extends MetaTile:
	func has_flag(_flags:int):
		return false

class MockActionData extends ActionData:
	func get_deploy_tile_flags():
		return 0

class MockMetaTileWithFlags extends MockMetaTile:
	func has_flag(_flags: int) -> bool:
		return true

var controller: CardController
var mock_mouse_cell: MockMetaTile
var card_data:CardData = CARD_DATA.get_duplicate()

func before_each():
	# Load the Room scene
	var room_data = RoomData.new()
	room_data.setup(ROOM_PARAMS)
	var room = autofree(ROOM_SCENE.instantiate())
	room.room_data = room_data
	add_child(room)
	room.prepare()

	# Initialize the controller with the Room instance
	controller = autofree(CardController.new(room))
	add_child(controller)
	mock_mouse_cell = autofree(MockMetaTile.new())

# Test method
func test_handle_mouse_cell_updated():
	# Test case 1: mouse_cell is null
	controller._handle_mouse_cell_updated(null)
	# Assert expected state or behavior
	assert_null(controller._current_action_emitter, "Pending actions should be cleared when mouse_cell is null")

	# Test case 2: mouse_cell does not have required flags
	controller.handle_card_evoked(card_data)
	controller._handle_mouse_cell_updated(mock_mouse_cell as MetaTile)
	# Assert expected state or behavior
	assert_false(controller._current_action_emitter.has_pending_action(), "Pending actions should be cleared when mouse_cell does not have required flags")

	# Test case 3: mouse_cell has required flags
	var mock_mouse_cell_with_flags = autofree(MockMetaTileWithFlags.new())
	mock_mouse_cell_with_flags.tile_id = 303
	controller._handle_mouse_cell_updated(mock_mouse_cell_with_flags)
	# Assert expected state or behavior
	assert_true(controller._current_action_emitter.has_pending_action(), "Pending actions should be created when mouse_cell has required flags")

	# Test case 4: _warning_dialog_view is not null
	controller._warning_dialog_view = autofree(GUICombatWarningDialog.new())  # Mock warning dialog
	controller._handle_mouse_cell_updated(mock_mouse_cell)
	# Assert expected state or behavior
	assert_null(controller._warning_dialog_view, "Warning dialog should be freed when mouse_cell is updated")
