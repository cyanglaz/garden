class_name GUIBingoHeader
extends Control

const HEADER_LABEL_SCENE := preload("res://scenes/GUI/bingo_main/bingo_board/gui_bingo_header_label.tscn")
const TEXT := ["B", "I", "N", "G", "O"]

func _ready() -> void:
	var control_center := size/2
	
	var total_width := BingoBoard.SIZE * GUIBingoBoard.SPACE_SIZE.x + (BingoBoard.SIZE - 1)
	var total_height := BingoBoard.SIZE * GUIBingoBoard.SPACE_SIZE.y + (BingoBoard.SIZE - 1)
	var start_pos := control_center - Vector2(total_width, total_height) / 2 - Vector2(GUIBingoBoard.OFFSET, GUIBingoBoard.OFFSET) * BingoBoard.SIZE /2
	
	for col in range(BingoBoard.SIZE):
		var label:Label = HEADER_LABEL_SCENE.instantiate()
		add_child(label)
		# Calculate position for each space
		var x_pos := start_pos.x + col * GUIBingoBoard.SPACE_SIZE.x + GUIBingoBoard.OFFSET *col
		label.position = Vector2(x_pos, 0)
		label.size = GUIBingoBoard.SPACE_SIZE
		label.text = TEXT[col]
