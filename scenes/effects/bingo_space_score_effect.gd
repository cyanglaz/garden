class_name BingoSpaceScoreEffect
extends AnimatedSpriteActionEffect

@onready var label: Label = %Label

var _score:int = 0

func _ready() -> void:
	super._ready()
	label.text = str(_score)

func set_score(val:int) -> void:
	_score = val
