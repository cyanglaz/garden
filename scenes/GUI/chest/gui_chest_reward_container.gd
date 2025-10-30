class_name GUIChestRewardContainer
extends Control

const PADDING := 16
const INITIAL_SCALE_FACTOR:float = 0.5
const CARD_DROP_DELAY := 0.05
const Y_OFFSET := 8.0
const SPAWN_DELAY := 0.05
const SPAWN_TRANSITION_TIME := 0.4

const GUI_CHEST_REWARD_CARD_SCENE := preload("res://scenes/GUI/chest/gui_chest_reward_card.tscn")

var _reward_datas:Array

func spawn_cards(number_of_cards:int, rarity:int, spawn_position:Vector2) -> void:
	_reward_datas = MainDatabase.tool_database.roll_tools(number_of_cards, rarity)
	Util.remove_all_children(self)
	for pick in _reward_datas:
		var gui_reward_card: GUIChestRewardCard = GUI_CHEST_REWARD_CARD_SCENE.instantiate()
		add_child(gui_reward_card)
		gui_reward_card.hide()
		gui_reward_card.update_with_data(pick)
	await _animate_spawn(spawn_position)

func _animate_spawn(spawn_position:Vector2) -> void:
	for child in get_children():
		child.global_position = spawn_position
		child.scale = Vector2.ONE * INITIAL_SCALE_FACTOR
	var tween:Tween = Util.create_scaled_tween(self)
	for i in range(get_child_count()):
		var child = get_child(i)
		var target_position: Vector2 = _get_all_reward_positions()[i]
		tween.tween_property(child, "global_position", target_position, SPAWN_TRANSITION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(SPAWN_DELAY * i)
		tween.tween_property(child, "scale", Vector2.ONE, SPAWN_TRANSITION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(SPAWN_DELAY * i)
	await tween.finished

func _get_all_reward_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var total_width: float = 0.0
	var child_count: int = get_child_count()

	# Calculate total width needed for all cards including padding
	for i in range(child_count):
		var child = get_child(i)
		total_width += child.size.x
		if i < child_count - 1:
			total_width += PADDING

	# Calculate starting x position to center the cards
	var start_x: float = (size.x - total_width) / 2.0
	var current_x: float = start_x

	# Calculate positions for each card
	for i in range(child_count):
		var child = get_child(i)
		var target_position: Vector2 = Vector2(current_x, (size.y - child.size.y) / 2.0 + Y_OFFSET)
		positions.append(target_position)
		current_x += child.size.x + PADDING

	return positions
