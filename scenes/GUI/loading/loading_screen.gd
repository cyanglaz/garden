class_name LoadingScreen
extends CanvasLayer

const LOAD_INTERVAL := 0.5

@onready var label: Label = %Label
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var next_scene_path:String
var _progress : = []
var _progress_number :float : set = _set_progress_number
var _next_scene:PackedScene = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _next_scene:
		queue_free()
		return
	_progress_number = 0
	animated_sprite_2d.play("walk")
	var errpr := ResourceLoader.load_threaded_request(next_scene_path)
	if errpr == null:
		# TODO properly handle this error
		printerr("error occurred while getting the scene ", errpr)
		return
	
func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(next_scene_path, _progress)
	if _progress_number >= 1:
		assert(load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED)
		_next_scene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(_next_scene)
		queue_free()
		return
	_progress_number = _progress[0]

func _set_progress_number(val:float):
	_progress_number = val
	label.text = str(_progress_number * 100 as int, "%")
