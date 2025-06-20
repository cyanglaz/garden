extends Node2D

@onready var character_explode: CharacterExplode = $CharacterExplode
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#sprite_2d.hide()
	character_explode.play_with_sprite(sprite_2d)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
