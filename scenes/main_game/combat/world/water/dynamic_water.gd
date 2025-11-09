class_name DynamicWater
extends Node2D

const SPRING_SCENE := preload("res://scenes/main_game/combat/world/water/water_spring.tscn")

const SPLASH_SPEED := {
	"field": 0.7,
}

@export_group("Water Body")
@export var water_color:Color = Constants.COLOR_BLUE_4
@export var depth := 200

@export_group("Physics")
@export var k := 0.015
@export var d := 0.1 # How fast recovers from the spring
@export var spread := 0.0002
@export var spring_number := 22
@export var distance_between_springs := 16

@export_group("Outer Border")
@export var outer_border_thickness := 2
@export var outer_border_color:Color = Constants.COLOR_WHITE
@export var outer_border_texture:Texture2D = null

@export_group("Inner Border")
@export var inner_border_thickness := 0
@export var inner_border_color:Color = Constants.COLOR_WHITE
@export var inner_border_texture:Texture2D = null

@onready var water_polygon: Polygon2D = %WaterPolygon
@onready var water_border: SmoothLine = %WaterBorder
@onready var water_border_2: SmoothLine = %WaterBorder2
@onready var spring_container: Node2D = %SpringContainer

var target_height := global_position.y
var bottom := target_height + depth

var springs := []
var passes = 8

func _ready() -> void:
	water_polygon.color = water_color
	water_border.width = outer_border_thickness
	water_border.default_color = outer_border_color
	water_border.texture = outer_border_texture
	if inner_border_thickness > 0:
		water_border_2.width = inner_border_thickness
		water_border_2.default_color = inner_border_color
		water_border_2.texture = inner_border_texture
	var starting_x := -distance_between_springs * (spring_number / 2.0)
	for i in spring_number:
		var x_position := starting_x + distance_between_springs * i
		var water_spring := SPRING_SCENE.instantiate()
		spring_container.add_child(water_spring)
		springs.append(water_spring)
		water_spring.initialize()
		water_spring.position.x = x_position
		water_spring.set_collision_width(distance_between_springs)
		water_spring.area_entered.connect(_on_water_spring_area_entered.bind(i))
	splash(5, 5)
	splash(4, 5)
	#splash(6, 5)
	#splash(7, 5)

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
	
	draw_border()
	draw_water_body(water_border.curve)

func splash(index, speed) -> void:
	assert(index >= 0 && index < springs.size())
	springs[index].velocity += speed

func draw_water_body(border_curve: Curve2D) -> void:

	var points := border_curve.get_baked_points()
	var water_polygon_points := points

	var first_index := 0
	var last_index := points.size() - 1
	# add right bottom point
	water_polygon_points.append(Vector2(points[last_index].x, bottom))
	water_polygon_points.append(Vector2(points[first_index].x, bottom))
	
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
	water_border.queue_update()

	if inner_border_thickness > 0:
		var curve_2 := Curve2D.new()
		for i in surface_points.size():
			curve_2.add_point(surface_points[i]+Vector2.DOWN * inner_border_thickness)
		water_border_2.curve = curve_2
		water_border_2.smooth()
		water_border_2.queue_update()
	
func _on_water_spring_area_entered(_area: Area2D, index: int) -> void:
	#var speed = 0
	#var water_spring = springs[index]
	#if body is CharacterBody2D:
		#speed = (body as CharacterBody2D).velocity.y * water_spring.motion_factor
	var speed = SPLASH_SPEED["field"]
	splash(index, speed)
	pass
