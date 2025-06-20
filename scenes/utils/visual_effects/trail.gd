class_name Trail
extends Line2D

@export var decay_time := 0.5

@export_category("performance")
@export var max_points := 30
@export var min_spawn_distance := 1
@export var tick_speed := 0.0

@onready var _curve := Curve2D.new()

var _scaled_with_parent := false
var _tick = tick_speed + 0.1

static func create() -> Trail:
	var scn = load("res://scenes/utils/visual_effects/trail.tscn")
	return scn.instantiate()

func _enter_tree() -> void:
	clear_points()
	if _curve:
		_curve.clear_points()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !_scaled_with_parent:
		width *= get_parent().scale.x
		max_points = clamp(max_points * get_parent().scale.x, max_points, 100)
		_scaled_with_parent = true
		
	if _tick > tick_speed:
		var point_position = get_parent().position
		_tick = 0
		_curve.add_point(point_position)
		if _curve.get_baked_points().size() > max_points:
			_curve.remove_point(0)
		points = _curve.get_baked_points()
	else:
		_tick += delta

func stop():
	set_process(false)
	var decay_tween = Util.create_scaled_tween(self)
	decay_tween.tween_property(self, "modulate:a", 0, decay_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	decay_tween.play()
	await decay_tween.finished
	queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_curve.clear_points()
