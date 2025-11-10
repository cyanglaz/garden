@tool
class_name SmoothLine
extends Line2D

@export var spline_length: float = 10

var curve:Curve2D = Curve2D.new()

func queue_update() -> void:
	points.clear()
	points = curve.get_baked_points()

func straighten() -> void:
	for i in curve.get_point_count():
		curve.set_point_in(i, Vector2())
		curve.set_point_out(i, Vector2())

func smooth() -> void:
	var point_count = curve.get_point_count()
	for i in range(1, point_count-1):
		var spline = _get_spline(i)
		curve.set_point_in(i, -spline)
		curve.set_point_out(i, spline)

func _get_spline(i: int) -> Vector2:
	var last_point = _get_point(i - 1)
	var next_point = _get_point(i + 1)
	var spline = last_point.direction_to(next_point) * spline_length
	return spline

func _get_point(i: int) -> Vector2:
	var point_count = curve.get_point_count()
	i = wrapi(i, 0, point_count)
	return curve.get_point_position(i)
