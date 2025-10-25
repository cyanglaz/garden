class_name MainGame
extends Node2D

const MAP_MAIN_SCENE := preload("res://scenes/main_game/map/map_main.tscn")
const COMBAT_MAIN_SCENE := preload("res://scenes/main_game/combat/combat_main.tscn")

const INITIAL_RATING_VALUE := 100
const INITIAL_RATING_MAX_VALUE := 100

@export var player:PlayerData
@export var test_tools:Array[ToolData]
@export var test_number_of_fields := 0
@export var test_contract:ContractData

@onready var gui_main_game: GUIMainGame = %GUIMainGame
@onready var feedback_camera_2d: FeedbackCamera2D = %FeedbackCamera2D
@onready var node_container: Node2D = %NodeContainer

var session_seed := 0

#Scenes
var combat_main:CombatMain
var map_main:MapMain
var _current_scene:Node2D

var chapter_manager:ChapterManager = ChapterManager.new()
var contract_generator:ContractGenerator = ContractGenerator.new()
var card_pool:Array[ToolData]
var rating:ResourcePoint = ResourcePoint.new()
var map_generator:MapGenerator = MapGenerator.new()
var _gold:int = 0: set = _set_gold
var _warning_manager:WarningManager = WarningManager.new(self)

func _ready() -> void:
	Singletons.main_game = self
	PopupThing.clear_popup_things()
	
	rating.setup(INITIAL_RATING_VALUE, INITIAL_RATING_MAX_VALUE)

	if test_tools.is_empty():
		card_pool = player.initial_tools
	else:
		card_pool = test_tools

	#gui main signals
	gui_main_game.update_player(player)
	gui_main_game.bind_with_rating(rating)
	gui_main_game.bind_cards(card_pool)
	
	contract_generator.generate_bosses(1)

	_register_global_events()

	Events.request_update_gold.emit(0, false)
	_start_new_chapter()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("view_detail"):
		gui_main_game.show_info_view()

func _register_global_events() -> void:
	Events.request_rating_update.connect(_on_request_rating_update)
	Events.request_update_gold.connect(_on_request_update_gold)
	Events.request_show_warning.connect(_on_request_show_warning)
	Events.request_hide_warning.connect(_on_request_hide_warning)
	Events.request_show_custom_error.connect(_on_request_show_custom_error)
	Events.request_hide_custom_error.connect(_on_request_hide_custom_error)

#endregion

#region private

func _start_new_chapter() -> void:
	map_generator.generate(session_seed)
	chapter_manager.next_chapter()
	# Always start with a common node
	_start_combat_main_scene(contract_generator.common_contracts.pop_back())
	#combat_main.start(player.number_of_fields, card_pool, 3, test_contract)

func _generate_chapter_data() -> void:
	map_generator.generate(session_seed)
	var normal_node_count := map_generator.get_node_count(MapNode.NodeType.NORMAL) + map_generator.get_node_count(MapNode.NodeType.EVENT)
	var elite_node_count := map_generator.get_node_count(MapNode.NodeType.ELITE)
	var boss_node_count := map_generator.get_node_count(MapNode.NodeType.BOSS)
	contract_generator.generate_contracts(chapter_manager.current_chapter, normal_node_count, elite_node_count, boss_node_count)

func _game_over() -> void:
	pass

#endregion

#region scenes

func _start_combat_main_scene(contract:ContractData) -> void:
	if _current_scene:
		_current_scene.queue_free()
	combat_main = COMBAT_MAIN_SCENE.instantiate()
	node_container.add_child(combat_main)
	_current_scene = combat_main
	combat_main.start(player.number_of_fields, card_pool, 3, contract)

func _start_map_main_scene() -> void:
	if _current_scene:
		_current_scene.queue_free()
	map_main = MAP_MAIN_SCENE.instantiate()
	node_container.add_child(map_main)
	_current_scene = map_main
	map_main.update_with_map(map_generator.layers)

#endregion

#region setter/getter

func _set_gold(val:int) -> void:
	_gold = val

#endregion

#region global events

func _on_request_rating_update(val:int) -> void:
	rating.value += val
	await gui_main_game.rating_update_finished
	if rating.value == 0:
		_game_over()

func _on_request_update_gold(val:int, animated:bool) -> void:
	_gold += val
	await gui_main_game.update_gold(val, animated)

func _on_request_show_warning(warning_type:WarningManager.WarningType) -> void:
	_warning_manager.show_warning(warning_type)

func _on_request_hide_warning(warning_type:WarningManager.WarningType) -> void:
	_warning_manager.hide_warning(warning_type)

func _on_request_show_custom_error(message:String, id:String) -> void:
	_warning_manager.show_custom_error(message, id)

func _on_request_hide_custom_error(id:String) -> void:
	_warning_manager.hide_custom_error(id)


#endregion

#region reward events

func _on_reward_finished(tool_data:ToolData, from_global_position:Vector2) -> void:
	if tool_data:
		card_pool.append(tool_data)
	await gui_main_game.gui_top_animation_overlay.animate_add_card_to_deck(from_global_position, tool_data)
	# go to map
	pass

#endregion
