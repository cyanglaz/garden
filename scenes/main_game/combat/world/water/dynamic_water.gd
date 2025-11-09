class_name DynamicWater
extends Node2D

const SPRING_SCENE := preload("res://scenes/main_game/combat/world/water/water_spring.tscn")

@export var k := 0.015
@export var d := 0.03
@export var spread := 0.0002
@export var distance_between_springs := 8
@export var spring_number := 20
@export var depth := 1000
@export var border_thickness := 4

@onready var water_polygon: Polygon2D = %WaterPolygon
@onready var water_border: SmoothPath = %WaterBorder

var target_height := global_position.y
var bottom := target_height + depth

var springs := []
var passes = 8

func _ready() -> void:
	water_border.line_width = border_thickness 
	for i in spring_number:
		var x_position := distance_between_springs * i
		var water_spring := SPRING_SCENE.instantiate()
		add_child(water_spring)
		springs.append(water_spring)
		water_spring.initialize()
		water_spring.position.x = x_position
	splash(6, 5)
	#splash(5, 5)
	#splash(4, 5)

func _physics_process(_delta: float) -> void:
	for water_spring:WaterSpring in springs:
		water_spring.water_update(k, d)
	var left_deltas := []
	var right_deltas := []
	
	for i in springs.size():
		left_deltas.append(0)
		right_deltas.append(0)

	for p in passes:
		for i in range(1, springs.size()):
			left_deltas[i] = spread * (springs[i].height - springs[i-1].height)
			springs[i-1].velocity += left_deltas[i]
		
		for i in range(0, springs.size() - 1):
			right_deltas[i] = spread * (springs[i].height - springs[i+1].height)
			springs[i+1].velocity += right_deltas[i]
	
	draw_water_body()
	draw_border()

func splash(index, speed) -> void:
	assert(index >= 0 && index < springs.size())
	springs[index].velocity += speed

func draw_water_body() -> void:
	var surface_points := []
	for i in springs.size():
		surface_points.append(springs[i].position)
		
	var first_index := 0
	var last_index := surface_points.size() - 1
	
	var water_polygon_points = surface_points
	# add right bottom point
	water_polygon_points.append(Vector2(surface_points[last_index].x, bottom))
	water_polygon_points.append(Vector2(surface_points[first_index].x, bottom))
	
	water_polygon.polygon = water_polygon_points
 
func draw_border() -> void:
	var curve := Curve2D.new()
	var surface_points := []
	for i in springs.size():
		surface_points.append(springs[i].position)
		
	for i in surface_points.size():
		curve.add_point(surface_points[i])
	water_border.curve = curve
	water_border.smooth()
	water_border.queue_redraw()
	#water_border.update()
	
