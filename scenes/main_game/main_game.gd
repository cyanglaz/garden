class_name MainGame
extends Node2D

const MAP_MAIN_SCENE := preload("res://scenes/main_game/map/map_main.tscn")
const COMBAT_MAIN_SCENE := preload("res://scenes/main_game/combat/combat_main.tscn")
const SHOP_MAIN_SCENE := preload("res://scenes/main_game/shop/shop_main.tscn")
const TOWN_MAIN_SCENE := preload("res://scenes/main_game/town/town_main.tscn")
const CHEST_MAIN_SCENE := preload("res://scenes/main_game/chest/chest_main.tscn")
const EVENT_MAIN_SCENE := preload("res://scenes/main_game/event/event_main.tscn")

const INITIAL_HP_VALUE := "res://data/player/player_pollinator.tres"
const SCENE_TRANSITION_TIME := 0.2
const NUMBER_OF_CHAPTERS := 1
const EVENT_CHANCE := 0.5

@export var player_data:PlayerData
@export var test_data:MainGameTest

@onready var gui_main_game: GUIMainGame = %GUIMainGame
@onready var node_container: Node2D = %NodeContainer
@onready var map_main: MapMain = %MapMain

var session_seed := 0

#Scenes
var _current_scene:Node2D: get = _get_current_scene

var chapter_manager:ChapterManager = ChapterManager.new()
var card_pool:Array[ToolData]
var trinket_manager:TrinketManager = TrinketManager.new()
var hp:ResourcePoint = ResourcePoint.new()
var gold:int = 0
var _warning_manager:WarningManager = WarningManager.new(self)
var _benched_events:Array = []

func _ready() -> void:
	Singletons.main_game = self
	hp.setup(player_data.hp, player_data.hp)
	if test_data && !test_data.test_tools.is_empty():
		card_pool = test_data.test_tools
	else:
		card_pool = player_data.initial_tools

	if test_data && !test_data.test_trinket_datas.is_empty():
		trinket_manager.setup(test_data.test_trinket_datas)
	else:
		trinket_manager.setup(player_data.initial_trinkets)

	#gui main signals
	gui_main_game.update_player(player_data)
	gui_main_game.bind_with_hp(hp)
	gui_main_game.bind_cards(card_pool)
	gui_main_game.bind_trinkets(trinket_manager)

	map_main.node_selected.connect(_on_map_node_selected)
	
	_register_global_events()

	Events.request_update_gold.emit(0, false)
	_on_request_update_gold(10, false)
	_start_new_chapter()

func _register_global_events() -> void:
	Events.request_hp_update.connect(_on_request_hp_update)
	Events.request_max_hp_update.connect(_on_request_max_hp_update)
	Events.request_update_gold.connect(_on_request_update_gold)
	Events.request_show_warning.connect(_on_request_show_warning)
	Events.request_hide_warning.connect(_on_request_hide_warning)
	Events.request_show_custom_error.connect(_on_request_show_custom_error)
	Events.request_hide_custom_error.connect(_on_request_hide_custom_error)
	Events.bind_finished.connect(_on_bind_finished)
	Events.request_add_card_to_deck.connect(_on_request_add_card_to_deck)
	Events.request_remove_card_from_deck.connect(_on_request_remove_card_from_deck)
	Events.request_add_trinket_to_collection.connect(_on_request_add_trinket_to_collection)

#endregion

#region private

func _start_new_chapter() -> void:
	chapter_manager.next_chapter()
	_generate_chapter_data()
	_benched_events = MainDatabase.event_database.get_events_by_chapter(chapter_manager.current_chapter)

	#_start_map_main_scene()
	# Always start with a common node
	if test_data && test_data.test_combat:
		_start_combat_main_scene.call_deferred(test_data.test_combat)
	else:
		_start_combat_main_scene.call_deferred(chapter_manager.fetch_common_combat_data())
	#_start_event()
	#_start_chest()
	#_start_town()
	#_game_over()
	#_game_win()
	#_start_shop()

func _generate_chapter_data() -> void:
	map_main.generate_map(session_seed)

func _game_over() -> void:
	gui_main_game.game_over()

func _game_win() -> void:
	gui_main_game.game_win()

#endregion

#region scenes

func _remove_current_scene() -> void:
	if _current_scene != null:
		_current_scene.queue_free()

func _start_combat_main_scene(combat:CombatData) -> void:
	var combat_main:CombatMain = COMBAT_MAIN_SCENE.instantiate()
	combat_main.test_weather = test_data.test_weather
	node_container.add_child(combat_main)
	combat_main.reward_finished.connect(_on_reward_finished)
	combat_main.beat_final_boss.connect(_on_beat_final_boss)
	start_scene_transition()
	combat_main.start(card_pool, 3, combat, chapter_manager.current_chapter, player_data, trinket_manager.trinket_pool)

func _start_shop() -> void:
	var shop_main = SHOP_MAIN_SCENE.instantiate()
	shop_main.shop_button_pressed.connect(_on_shop_button_pressed)
	shop_main.finish_button_pressed.connect(_on_shop_finish_button_pressed)
	node_container.add_child(shop_main)
	start_scene_transition()
	shop_main.start(gold, trinket_manager.trinket_pool)

func _start_town() -> void:
	var town_main = TOWN_MAIN_SCENE.instantiate()
	town_main.town_finished.connect(_on_town_finished)
	node_container.add_child(town_main)
	town_main.setup_with_card_pool(card_pool)
	start_scene_transition()

func _start_chest() -> void:
	var chest_main: ChestMain = CHEST_MAIN_SCENE.instantiate()
	chest_main.chest_finished.connect(_on_chest_finished)
	node_container.add_child(chest_main)
	start_scene_transition()
	chest_main.start(trinket_manager.trinket_pool)

func _start_event() -> void:
	var event_main:EventMain = EVENT_MAIN_SCENE.instantiate()
	event_main.event_finished.connect(_on_event_finished)
	node_container.add_child(event_main)
	start_scene_transition()
	if _benched_events.is_empty():
		_benched_events = MainDatabase.event_database.get_events_by_chapter(chapter_manager.current_chapter)
	var next_event_data:EventData = _benched_events.pop_back()
	if test_data && test_data.test_event_data:
		next_event_data = test_data.test_event_data
	event_main.start(next_event_data, self)

func start_scene_transition() -> void:
	map_main.hide()
	await gui_main_game.transition(TransitionOverlay.Type.FADE_IN, SCENE_TRANSITION_TIME)

func _complete_current_node() -> void:
	map_main.complete_current_node()
	await gui_main_game.transition(TransitionOverlay.Type.FADE_OUT, SCENE_TRANSITION_TIME)
	_current_scene.queue_free()
	map_main.show()
	await gui_main_game.transition(TransitionOverlay.Type.FADE_IN, SCENE_TRANSITION_TIME)

#endregion

#region main scene events

func _on_reward_finished() -> void:
	# go to map
	_complete_current_node()

func _on_beat_final_boss() -> void:
	_game_win()

func _on_shop_button_pressed(cost: int) -> void:
	if cost > 0:
		Events.request_update_gold.emit(-cost, true)
		(_current_scene as ShopMain).update_for_gold(gold)

func _on_shop_finish_button_pressed() -> void:
	_complete_current_node()

func _on_town_finished() -> void:
	_complete_current_node()

func _on_bind_finished(tool_data:ToolData, front_card_data_to_erase:ToolData, back_card_data_to_erase:ToolData) -> void:
	assert(card_pool.has(front_card_data_to_erase), "Front card not in card pool")
	assert(card_pool.has(back_card_data_to_erase), "Back card not in card pool")
	card_pool.erase(front_card_data_to_erase)
	card_pool.erase(back_card_data_to_erase)
	card_pool.append(tool_data)

func _on_request_add_card_to_deck(tool_data:ToolData, bind_card_global_position:Vector2) -> void:
	card_pool.append(tool_data)
	await gui_main_game.gui_top_animation_overlay.animate_add_card_to_deck(bind_card_global_position, tool_data)

func _on_request_remove_card_from_deck(tool_data:ToolData) -> void:
	card_pool.erase(tool_data)

func _on_request_add_trinket_to_collection(trinket_data: TrinketData, from_global_position: Vector2) -> void:
	trinket_manager.add_trinket(trinket_data)
	await _apply_trinket_collect_hook(trinket_data)
	await gui_main_game.gui_top_animation_overlay.animate_add_trinket_to_collection(from_global_position, trinket_data)

func _apply_trinket_collect_hook(trinket_data: TrinketData) -> void:
	var trinket: PlayerTrinket = load(PlayerTrinketsContainer.PLAYER_TRINKET_SCENE_PREFIX % trinket_data.id).instantiate()
	trinket.data = trinket_data
	add_child(trinket)
	if trinket.has_collect_hook():
		await trinket.handle_collect_hook()
	trinket.queue_free()

func _on_chest_finished() -> void:
	_complete_current_node()

func _on_event_finished(meta:Variant) -> void:
	if meta is ToolData:
		card_pool.append(meta)
		await gui_main_game.gui_top_animation_overlay.animate_add_card_to_deck(gui_main_game.gui_top_animation_overlay.size/2, meta)
	_complete_current_node()

#endregion

#region global events

func _on_request_hp_update(val:int, operation:ActionData.OperatorType) -> void:
	match operation:
		ActionData.OperatorType.INCREASE:
			hp.value += val
		ActionData.OperatorType.DECREASE:
			hp.value -= val
		ActionData.OperatorType.EQUAL_TO:
			hp.value = val
	await gui_main_game.animate_hp_update(val)
	if hp.value == 0:
		_game_over()

func _on_request_max_hp_update(val:int, operation:ActionData.OperatorType) -> void:
	match operation:
		ActionData.OperatorType.INCREASE:
			hp.max_value += val
		ActionData.OperatorType.DECREASE:
			hp.max_value -= val
		ActionData.OperatorType.EQUAL_TO:
			hp.max_value = val

func _on_request_update_gold(val:int, animated:bool) -> void:
	var diff := val
	if gold + diff < 0:
		diff = -gold
	gold += diff
	await gui_main_game.update_gold(diff, animated)

func _on_request_show_warning(warning_type:WarningManager.WarningType) -> void:
	_warning_manager.show_warning(warning_type)

func _on_request_hide_warning(warning_type:WarningManager.WarningType) -> void:
	_warning_manager.hide_warning(warning_type)

func _on_request_show_custom_error(message:String, id:String) -> void:
	_warning_manager.show_custom_error(message, id)

func _on_request_hide_custom_error(id:String) -> void:
	_warning_manager.hide_custom_error(id)

#endregion

#region map events

func _on_map_node_selected(node:MapNode) -> void:
	var node_type:MapNode.NodeType = node.type
	if node.type == MapNode.NodeType.EVENT:
		if randf() > EVENT_CHANCE:
			# Chance for non-event nodes
			const EVENT_NODES := [MapNode.NodeType.CHEST, MapNode.NodeType.SHOP, MapNode.NodeType.TOWN, MapNode.NodeType.NORMAL]
			node_type = Util.unweighted_roll(EVENT_NODES, 1).front()
	await gui_main_game.transition(TransitionOverlay.Type.FADE_OUT, SCENE_TRANSITION_TIME)
	match node_type:
		MapNode.NodeType.NORMAL:
			_start_combat_main_scene(chapter_manager.fetch_common_combat_data())
		MapNode.NodeType.ELITE:
			_start_combat_main_scene(chapter_manager.fetch_elite_combat_data())
		MapNode.NodeType.BOSS:
			_start_combat_main_scene(chapter_manager.fetch_boss_combat_data())
		MapNode.NodeType.SHOP:
			_start_shop()
		MapNode.NodeType.TOWN:
			_start_town()
		MapNode.NodeType.CHEST:
			_start_chest()
		MapNode.NodeType.EVENT:
			_start_event()
		_:
			assert(false, "Invalid event node type: %s" % node_type)

# region getter

func _get_current_scene() -> Node2D:
	if node_container.get_child_count() == 0:
		return null
	return node_container.get_child(0)

#endregion
