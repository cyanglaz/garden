class_name GUIRewardCardsMain
extends Control

const CARD_PADDING := 16
const SCALE_FACTOR:float = 1.5
const CARD_DROP_DELAY := 0.05
const CARD_Y_OFFSET := 8.0

const GUI_TOOL_CARD_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")

signal card_selected(tool_data:ToolData, from_global_position:Vector2)

@onready var cards_container: Control = %CardsContainer
@onready var gui_booster_pack_image: GUIBoosterPackImage = %GUIBoosterPackImage
@onready var choose_card_title: Label = %ChooseCardTitle
@onready var skip_card_button: GUIRichTextButton = %SkipCardButton

var _picks:Array[ToolData] = []

func _ready() -> void:
	choose_card_title.text = Util.get_localized_string("REWARD_CARDS_MAIN_CHOOSE_CARD_TITLE_TEXT")
	skip_card_button.pressed.connect(_on_skip_card_button_pressed)

func spawn_cards_with_pack_type(booster_pack_type:ContractData.BoosterPackType, pack_button_g_position:Vector2) -> void:
	choose_card_title.hide()
	skip_card_button.hide()
	show()
	_picks = _pick_card_datas(booster_pack_type)
	Util.remove_all_children(cards_container)
	for pick in _picks:
		var gui_tool_card_button: GUIToolCardButton = GUI_TOOL_CARD_SCENE.instantiate()
		gui_tool_card_button.mouse_entered.connect(_on_mouse_entered.bind(gui_tool_card_button))
		gui_tool_card_button.mouse_exited.connect(_on_mouse_exited.bind(gui_tool_card_button))
		gui_tool_card_button.pressed.connect(_on_card_selected.bind(pick, gui_tool_card_button))
		cards_container.add_child(gui_tool_card_button)
		gui_tool_card_button.hide()
		gui_tool_card_button.update_with_tool_data(pick)
	await _animate_pack_open(booster_pack_type, pack_button_g_position)
	await _animate_card_fly_up()
	await _animate_card_drop()

func _pick_card_datas(booster_pack_type:ContractData.BoosterPackType) -> Array[ToolData]:
	var common_chance := ContractData.BOOSTER_PACK_CARD_CHANCES[booster_pack_type][0] as int
	var rare_chance := ContractData.BOOSTER_PACK_CARD_CHANCES[booster_pack_type][1] as int
	var legendary_chance := ContractData.BOOSTER_PACK_CARD_CHANCES[booster_pack_type][2] as int
	var total_card_count := ContractData.NUMBER_OF_CARDS_IN_BOOSTER_PACK
	var common_card_cont := ContractData.BOOSTER_PACK_CARD_BASE_COUNTS[booster_pack_type][0] as int
	var rare_card_count := ContractData.BOOSTER_PACK_CARD_BASE_COUNTS[booster_pack_type][1] as int
	var legendary_card_count := ContractData.BOOSTER_PACK_CARD_BASE_COUNTS[booster_pack_type][2] as int

	var card_number_to_roll := total_card_count - common_card_cont - rare_card_count - legendary_card_count
	for i in card_number_to_roll:
		var count_roll := Util.weighted_roll([0, 1, 2], [common_chance, rare_chance, legendary_chance]) as int
		match count_roll:
			0:
				common_card_cont += 1
			1:
				rare_card_count += 1
			2:
				legendary_card_count += 1
	
	var result:Array[ToolData] = []
	var common_cards:Array[ToolData] = MainDatabase.tool_database.roll_tools(common_card_cont, 0)
	var rare_cards:Array[ToolData] = MainDatabase.tool_database.roll_tools(rare_card_count, 1)
	var legendary_cards:Array[ToolData] = MainDatabase.tool_database.roll_tools(legendary_card_count, 2)
	result.append_array(common_cards)
	result.append_array(rare_cards)
	result.append_array(legendary_cards)
	result.shuffle()

	return result

func _get_all_card_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var total_width: float = 0.0
	var child_count: int = cards_container.get_child_count()

	# Calculate total width needed for all cards including padding
	for i in range(child_count):
		var child = cards_container.get_child(i)
		total_width += child.size.x
		if i < child_count - 1:
			total_width += CARD_PADDING

	# Calculate starting x position to center the cards
	var start_x: float = (size.x - total_width) / 2.0
	var current_x: float = start_x

	# Calculate positions for each card
	for i in range(child_count):
		var child = cards_container.get_child(i)
		var target_position: Vector2 = Vector2(current_x, (size.y - child.size.y) / 2.0 + CARD_Y_OFFSET)
		positions.append(target_position)
		current_x += child.size.x + CARD_PADDING

	return positions

func _animate_pack_open(booster_pack_type:ContractData.BoosterPackType, g_position:Vector2) -> void:
	gui_booster_pack_image.show()
	gui_booster_pack_image.update_with_booster_pack_type(booster_pack_type)
	gui_booster_pack_image.global_position = g_position
	gui_booster_pack_image.pivot_offset = gui_booster_pack_image.size/2
	gui_booster_pack_image.has_outline = true
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(gui_booster_pack_image, "scale", Vector2.ONE * SCALE_FACTOR, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _animate_card_fly_up() -> void:
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i in cards_container.get_child_count():
		var child := cards_container.get_child(i)
		var initial_positions :Vector2 = gui_booster_pack_image.position + gui_booster_pack_image.size/2-child.size/2
		var target_position := Vector2(self.size.x/2 - child.size.x/2, 0 - child.size.y)
		child.global_position = initial_positions
		child.scale = Vector2.ONE * SCALE_FACTOR
		child.pivot_offset = child.size/2
		Util.create_scaled_timer(CARD_DROP_DELAY * i).timeout.connect(func() -> void: child.visible = true)
		tween.tween_property(child, "global_position", target_position, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(CARD_DROP_DELAY * i)
		tween.tween_property(child, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(CARD_DROP_DELAY * i)
	await tween.finished
	gui_booster_pack_image.hide()
	gui_booster_pack_image.scale = Vector2.ONE

func _animate_card_drop() -> void:
	var final_positions := _get_all_card_positions()
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i in cards_container.get_child_count():
		var child := cards_container.get_child(i)
		child.global_position = Vector2(self.size.x/2 - child.size.x/2, 0 - child.size.y)
		var target_position: Vector2 = final_positions[i]
		tween.tween_property(child, "global_position", target_position, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(CARD_DROP_DELAY * i)
	for i in cards_container.get_child_count():
		var child:GUIToolCardButton = cards_container.get_child(i)
		child.mouse_disabled = false
	await tween.finished
	choose_card_title.show()
	skip_card_button.show()

func _handle_card_selection_ended(tool_data:ToolData, from_global_position:Vector2) -> void:
	choose_card_title.hide()
	skip_card_button.hide()
	Util.remove_all_children(cards_container)
	hide()
	card_selected.emit(tool_data, from_global_position)

func _on_mouse_entered(gui_tool_card_button:GUIToolCardButton) -> void:
	gui_tool_card_button.card_state = GUIToolCardButton.CardState.HIGHLIGHTED

func _on_mouse_exited(gui_tool_card_button:GUIToolCardButton) -> void:
	gui_tool_card_button.card_state = GUIToolCardButton.CardState.NORMAL

func _on_card_selected(tool_data:ToolData, gui_tool_card_button:GUIToolCardButton) -> void:
	var from_global_position:Vector2 = gui_tool_card_button.global_position
	_handle_card_selection_ended(tool_data, from_global_position)

func _on_skip_card_button_pressed() -> void:
	_handle_card_selection_ended(null, Vector2.ZERO)
