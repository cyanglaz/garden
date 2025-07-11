class_name GUIBingoBallHand
extends PanelContainer

const BALL_SCENE := preload("res://scenes/GUI/bingo_main/draw_box/gui_bingo_ball.tscn")
const DEFAULT_BALL_SPACE := 4.0
const MAX_HAND_AREA_WIDTH := 150
const CLEAR_TIME:float = 0.05
const DRAW_DELAY:float = 0.1
const MOVE_DURATION:float = 0.2
const REPOSITION_DURATION:float = 0.15

@onready var _hover_sound: AudioStreamPlayer2D = %HoverSound
@onready var _draw_area: Control = %DrawArea

var _ball_size:int

func _ready() -> void:
	var temp_bingo_ball := BALL_SCENE.instantiate()
	_ball_size = temp_bingo_ball.size.x
	temp_bingo_ball.queue_free()

func get_ball(index:int) -> GUIBingoBall:
	return _draw_area.get_child(index)

func get_ball_count() -> int:
	return _draw_area.get_children().size()

func clear() -> void:
	if _draw_area.get_children().size() == 0:
		return
	for child:GUIBingoBall in _draw_area.get_children():
		child.hide_warning_tooltip()
		child.queue_free()

func add_balls(balls:Array[BingoBallData]) -> void:
	var current_size :=  _draw_area.get_children().size()
	var positions := calculate_positions(balls.size() + current_size)
	for i in positions.size():
		var gui_ball:GUIBingoBall = null
		if i < current_size:
			gui_ball = _draw_area.get_child(i)
			gui_ball.hovered.disconnect(_on_ball_hovered.bind(i))
			gui_ball.hovered.connect(_on_ball_hovered.bind(i))
			gui_ball.show()
		else:
			var ball:BingoBallData = balls[i - current_size]
			gui_ball = BALL_SCENE.instantiate()
			gui_ball.hovered.connect(_on_ball_hovered.bind(i))
			_draw_area.add_child(gui_ball)
			gui_ball.bind_bingo_ball(ball)
		gui_ball.position = positions[i]

func get_ball_position(index:int) -> Vector2:
	var gui_ball:GUIBingoBall = _draw_area.get_child(index)
	return gui_ball.global_position

func calculate_positions(number_of_balls:int) -> Array[Vector2]:
	var ball_space := DEFAULT_BALL_SPACE
	var total_width := number_of_balls * _ball_size + ball_space * (number_of_balls - 1)
	# Reduce spacing if total width exceeds max width
	if total_width > MAX_HAND_AREA_WIDTH:
		# Calculate required space reduction
		var excess_width := total_width - MAX_HAND_AREA_WIDTH
		var required_space_per_gap := excess_width / (number_of_balls - 1)
		ball_space = DEFAULT_BALL_SPACE - required_space_per_gap
	var center := _draw_area.size/2
	var start_x := center.x - (number_of_balls * _ball_size + ball_space * (number_of_balls - 1)) / 2
	var result:Array[Vector2] = []
	for i in number_of_balls:
		var target_position := Vector2(start_x + i*_ball_size + i*ball_space, 0)
		result.append(target_position)
	result.reverse() # First ball is at the end of the array.
	return result 

func _on_ball_hovered(on:bool, index:int) -> void:
	var positions:Array[Vector2] = calculate_positions(_draw_area.get_children().size())
	if positions.size() < 2:
		return
	var ball_padding := positions[0].x - positions[1].x - _ball_size
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	if on && ball_padding < 0.0:
		# Push back other balls when one is hovered
		for i in _draw_area.get_children().size():
			var pos = positions[i]
			if i < index:
				# The positions are reversed
				pos.x += 1 - ball_padding # Push right balls 4 pixels left
			elif i > index:
				pos.x -= 1 - ball_padding# Push left balls 4 pixels right
			var gui_ball = _draw_area.get_child(i)
			gui_ball.position = pos
			tween.tween_property(gui_ball, "position", pos, REPOSITION_DURATION)
		_hover_sound.play()
	else:
		# Reset to default positions
		for i in _draw_area.get_children().size():
			var gui_ball = _draw_area.get_child(i)
			tween.tween_property(gui_ball, "position", positions[i], REPOSITION_DURATION)
