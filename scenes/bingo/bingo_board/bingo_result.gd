class_name BingoResult
extends RefCounted

enum BingoType {
	ROW,
	COLUMN,
	DIAGONAL
}

var bingo_type:BingoType
var spaces:Array[BingoSpaceData]
var index:int
var id:int

func _init(s:Array[BingoSpaceData], bt:BingoType) -> void:
	spaces = s
	bingo_type = bt
	id = _calculate_id()

func _calculate_id() -> int:
	var indexes := spaces.map(func(space:BingoSpaceData) -> int:
		return space.index
	)
	indexes.sort()
	return indexes.hash()
