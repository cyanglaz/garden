class_name FieldStatusRecycle
extends FieldStatus

const CONSECUTIVE_BALL_PROGRESS_DIFF := -0.05
const RECYCLE_BALLS_SCENE = preload("res://scenes/main_game/field/status/status_components/recycle_balls.tscn")

signal _adding_all_cards_finished()

var _card_added := -1
var _recycle_balls:Array

func update_for_plant(plant:Plant) -> void:
	super.update_for_plant(plant)
	_update_recycle_balls(plant)

func _has_add_water_hook(plant:Plant) -> bool:
	return plant != null

func _handle_add_water_hook(plant:Plant) -> void:
	Util.remove_all_children(self)
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("graywater").get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(plant) - GUIToolCardButton.SIZE / 2
	var number_of_cards := stack
	var cards:Array[ToolData] = []
	for i in number_of_cards:
		var tool_data_to_add:ToolData = tool_data.get_duplicate()
		tool_data_to_add.adding_to_deck_finished.connect(_on_card_added_to_deck_finished)
		cards.append(tool_data_to_add)
	_card_added = number_of_cards
	Events.request_add_tools_to_hand.emit(cards, from_position, true)
	await _adding_all_cards_finished

func _on_card_added_to_deck_finished() -> void:
	_card_added -= 1
	if _card_added == 0:
		_adding_all_cards_finished.emit()

func _update_recycle_balls(plant:Plant) -> void:
	var stack_diff:int = stack - _recycle_balls.size()
	var last_ball_progress:float = 0.0
	if _recycle_balls.size() > 0:
		last_ball_progress = _recycle_balls[_recycle_balls.size() - 1].current_progress
	if stack_diff > 0:
		for i in stack_diff:
			var recycle_ball:RecycleBalls = RECYCLE_BALLS_SCENE.instantiate()
			recycle_ball.update_with_plant(plant)
			recycle_ball.current_progress = last_ball_progress + CONSECUTIVE_BALL_PROGRESS_DIFF
			add_child(recycle_ball)
			_recycle_balls.append(recycle_ball)
			last_ball_progress = recycle_ball.current_progress
	elif stack_diff < 0:
		for i in abs(stack_diff):
			var recycle_balls:RecycleBalls = _recycle_balls.pop_back()
			recycle_balls.queue_free()
