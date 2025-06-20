class_name GUIBingoBoard
extends Control

const GUI_SPACE_SCENE := preload("res://scenes/GUI/bingo_main/bingo_board/gui_bingo_space.tscn")

signal refresh_finished()

@onready var _space_container: GridContainer = %SpaceContainer
@onready var _refresh_audio: AudioStreamPlayer = %RefreshAudio
var _refresh_finished_count:int = 0

func _ready() -> void:
	refresh_guis()

func refresh_guis() -> void:
	Util.remove_all_children(_space_container)
	for row in range(BingoBoard.SIZE):
		for col in range(BingoBoard.SIZE):
			var space = GUI_SPACE_SCENE.instantiate()
			space._gui_bingo_board = self
			_space_container.add_child(space)

func get_spaces() -> Array:
	return _space_container.get_children()

func get_space(index:int) -> GUIBingoSpace:
	return _space_container.get_child(index) as GUIBingoSpace

func display_ball(ball:BingoBallData, index:int) -> void:
	var gui_space:GUIBingoSpace = _space_container.get_child(index)
	gui_space.display_symbol(ball)

func refresh_with_board(board:Array, animated:bool = false) -> void:
	var spaces_to_refresh:Array[int] = []
	for i in board.size():
		spaces_to_refresh.append(i)
	await _refresh_spaces(board, spaces_to_refresh, animated)

func refresh_spaces_for_bingo(board:Array, bingo_results:Array[BingoResult], animated:bool = true) -> void:
	var spaces_to_remove:Array[int] = []
	for result:BingoResult in bingo_results:
		for space:BingoSpaceData in result.spaces:
			if spaces_to_remove.has(space.index):
				continue
			spaces_to_remove.append(space.index)
	await _refresh_spaces(board, spaces_to_remove, animated)

func _refresh_spaces(board:Array, space_indexes:Array[int], animated:bool = true) -> void:
	_refresh_finished_count = space_indexes.size()
	for i:int in space_indexes:
		var gui_space:GUIBingoSpace = _space_container.get_child(i)
		var bingo_space:BingoSpaceData = board[i]
		gui_space.refresh_finished.connect(_on_refresh_finished.bind(gui_space))
		gui_space.refresh_with_data(bingo_space, animated, 0.2)
	if animated:
		_refresh_audio.play()
		await refresh_finished

func get_ball_position(index:int) -> Vector2:
	return _space_container.get_child(index).global_position

func _on_refresh_finished(gui_space:GUIBingoSpace) -> void:
	gui_space.refresh_finished.disconnect(_on_refresh_finished)
	_refresh_finished_count -= 1
	if _refresh_finished_count == 0:
		refresh_finished.emit()
