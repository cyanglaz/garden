class_name GUIPileDisplay
extends PanelContainer

const BALL_SCALE:float = 0.8
const MAX_SCROLL_SIZE_Y := 128
const BINGO_BALL_SCENE: PackedScene = preload("res://scenes/GUI/bingo_main/draw_box/gui_bingo_ball.tscn")

@onready var _grid_container: GridContainer = %GridContainer
@onready var _scroll_container: ScrollContainer = %ScrollContainer

func update_with_pool(pool:Array[BingoBallData]) -> void:
	Util.remove_all_children(_grid_container)
	var ball_size := Vector2.ONE
	for ball_data in pool:
		var gui_bingo_ball: GUIBingoBall = BINGO_BALL_SCENE.instantiate()
		_grid_container.add_child(gui_bingo_ball)
		gui_bingo_ball.custom_minimum_size *= BALL_SCALE
		gui_bingo_ball.size = gui_bingo_ball.custom_minimum_size
		gui_bingo_ball.bind_bingo_ball(ball_data)
		ball_size = gui_bingo_ball.size
	@warning_ignore("integer_division")
	var rows := pool.size()/_grid_container.columns
	var v_seperation:int = _grid_container.get_theme_constant("v_separation")
	var content_height:float = rows * (ball_size.y + v_seperation) - v_seperation
	if content_height > MAX_SCROLL_SIZE_Y:
		_scroll_container.custom_minimum_size.y = MAX_SCROLL_SIZE_Y
		_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	else:
		_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_scroll_container.custom_minimum_size.y = 0
