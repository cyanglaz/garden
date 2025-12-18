class_name MainGame
extends Node2D

const MAP_MAIN_SCENE := preload("res://scenes/main_game/map/map_main.tscn")
const COMBAT_MAIN_SCENE := preload("res://scenes/main_game/combat/combat_main.tscn")
const SHOP_MAIN_SCENE := preload("res://scenes/main_game/shop/shop_main.tscn")
const TOWN_MAIN_SCENE := preload("res://scenes/main_game/town/town_main.tscn")
const CHEST_MAIN_SCENE := preload("res://scenes/main_game/chest/chest_main.tscn")

const INITIAL_HP_VALUE := 10
const INITIAL_HP_MAX_VALUE := 10
const SCENE_TRANSITION_TIME := 0.2

@export var player:PlayerData
@export var test_tools:Array[ToolData]
@export var test_weather:WeatherData
@export var test_combat:CombatData

@onready var gui_main_game: GUIMainGame = %GUIMainGame
@onready var node_container: Node2D = %NodeContainer
@onready var map_main: MapMain = %MapMain

var session_seed := 0

#Scenes
var _current_scene:Node2D: get = _get_current_scene

var chapter_manager:ChapterManager = ChapterManager.new()
var card_pool:Array[ToolData]
var hp:ResourcePoint = ResourcePoint.new()
var _gold:int = 0
var _warning_manager:WarningManager = WarningManager.new(self)

func _ready() -> void:
	Singletons.main_game = self
	
	hp.setup(INITIAL_HP_VALUE, INITIAL_HP_MAX_VALUE)

	if test_tools.is_empty():
		card_pool = player.initial_tools
	else:
		card_pool = test_tools

	#gui main signals
	gui_main_game.update_player(player)
	gui_main_game.bind_with_hp(hp)
	gui_main_game.bind_cards(card_pool)
	
	map_main.node_selected.connect(_on_map_node_selected)
	
	_register_global_events()

	Events.request_update_gold.emit(0, false)
	_start_new_chapter()

func _register_global_events() -> void:
	Events.request_hp_update.connect(_on_request_hp_update)
	Events.request_update_gold.connect(_on_request_update_gold)
	Events.request_show_warning.connect(_on_request_show_warning)
	Events.request_hide_warning.connect(_on_request_hide_warning)
	Events.request_show_custom_error.connect(_on_request_show_custom_error)
	Events.request_hide_custom_error.connect(_on_request_hide_custom_error)

#endregion

#region private

func _start_new_chapter() -> void:
	chapter_manager.next_chapter()
	_generate_chapter_data()

	#_start_map_main_scene()
	# Always start with a common node
	if test_combat:
		_start_combat_main_scene.call_deferred(test_combat)
	else:
		_start_combat_main_scene.call_deferred(chapter_manager.fetch_common_combat_data())
	#_start_shop()
	#_start_chest()
	#_start_town()

func _generate_chapter_data() -> void:
	map_main.generate_map(session_seed)

func _game_over() -> void:
	pass

#endregion

#region scenes

func _remove_current_scene() -> void:
	if _current_scene != null:
		_current_scene.queue_free()

func _start_combat_main_scene(combat:CombatData) -> void:
	var combat_main:CombatMain = COMBAT_MAIN_SCENE.instantiate()
	combat_main.test_weather = test_weather
	node_container.add_child(combat_main)
	combat_main.reward_finished.connect(_on_reward_finished)
	start_scene_transition()
	combat_main.start(card_pool, 3, combat)

func _start_shop() -> void:
	var shop_main = SHOP_MAIN_SCENE.instantiate()
	shop_main.tool_shop_button_pressed.connect(_on_tool_shop_button_pressed)
	shop_main.finish_button_pressed.connect(_on_shop_finish_button_pressed)
	node_container.add_child(shop_main)
	start_scene_transition()
	shop_main.start(_gold)

func _start_town() -> void:
	var town_main = TOWN_MAIN_SCENE.instantiate()
	town_main.town_finished.connect(_on_town_finished)
	node_container.add_child(town_main)
	start_scene_transition()

func _start_chest() -> void:
	var chest_main:ChestMain = CHEST_MAIN_SCENE.instantiate()
	chest_main.card_reward_selected.connect(_on_chest_card_reward_selected)
	chest_main.skipped.connect(_on_chest_reward_skipped)
	node_container.add_child(chest_main)
	start_scene_transition()

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

func _on_reward_finished(tool_data:ToolData, from_global_position:Vector2) -> void:
	if tool_data:
		card_pool.append(tool_data)
		await gui_main_game.gui_top_animation_overlay.animate_add_card_to_deck(from_global_position, tool_data)
	# go to map
	_complete_current_node()

func _on_tool_shop_button_pressed(tool_data:ToolData, from_global_position:Vector2) -> void:
	if tool_data:
		card_pool.append(tool_data)
		await gui_main_game.gui_top_animation_overlay.animate_add_card_to_deck(from_global_position, tool_data)
	Events.request_update_gold.emit(-tool_data.cost, true)
	(_current_scene as ShopMain).update_for_gold(_gold)

func _on_shop_finish_button_pressed() -> void:
	_complete_current_node()

func _on_town_finished() -> void:
	_complete_current_node()

func _on_chest_card_reward_selected(tool_data:ToolData, from_global_position:Vector2) -> void:
	if tool_data:
		card_pool.append(tool_data)
		await gui_main_game.gui_top_animation_overlay.animate_add_card_to_deck(from_global_position, tool_data)
	_complete_current_node()

func _on_chest_reward_skipped() -> void:
	_complete_current_node()
#endregion 

#region global events

func _on_request_hp_update(val:int) -> void:
	hp.value += val
	await gui_main_game.hp_update_finished
	if hp.value == 0:
		_game_over()

func _on_request_update_gold(val:int, animated:bool) -> void:
	var diff := val
	if _gold + diff < 0:
		diff = -_gold
	_gold += diff
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
		# TODO: Add more event nodes
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
		_:
			assert(false, "Invalid event node type: %s" % node_type)

# region getter

func _get_current_scene() -> Node2D:
	if node_container.get_child_count() == 0:
		return null
	return node_container.get_child(0)

#endregion
