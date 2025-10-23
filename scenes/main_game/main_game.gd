class_name MainGame
extends Node2D

const INITIAL_RATING_VALUE := 100
const INITIAL_RATING_MAX_VALUE := 100
const DETAIL_TOOLTIP_DELAY := 0.8


@export var player:PlayerData
@export var test_tools:Array[ToolData]
@export var test_number_of_fields := 0
@export var test_contract:ContractData

@onready var combat_main: CombatMain = %CombatMain
@onready var gui_main_game: GUIMainGame = %GUIMainGame
@onready var feedback_camera_2d: FeedbackCamera2D = %FeedbackCamera2D

var session_seed := 0

var chapter_manager:ChapterManager = ChapterManager.new()
var contract_generator:ContractGenerator = ContractGenerator.new()
var hovered_data:ThingData: set = _set_hovered_data
var card_pool:Array[ToolData]
var rating:ResourcePoint = ResourcePoint.new()
var _gold:int = 0: set = _set_gold
var _warning_manager:WarningManager = WarningManager.new()

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
	
	contract_generator.generate_bosses(1)

	Events.request_rating_update.connect(_on_request_rating_update)
	
	_start_new_chapter()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("view_detail"):
		if hovered_data:
			show_thing_info_view(hovered_data)
			hovered_data = null

#endregion

#region cards
func add_card_to_deck(tool_data:ToolData) -> void:
	card_pool.append(tool_data)

#endregion


#region gold

func update_gold(gold_diff:int, animated:bool) -> void:
	_gold += gold_diff
	await gui_main_game.update_gold(gold_diff, animated)

#endregion

#region gui

func add_control_to_overlay(control:Control) -> void:
	gui_main_game.add_control_to_overlay(control)

func clear_all_tooltips() -> void:
	gui_main_game.clear_all_tooltips()

func show_thing_info_view(data:Resource) -> void:
	gui_main_game.gui_thing_info_view.show_with_data(data)

func show_warning(warning_type:WarningManager.WarningType) -> void:
	_warning_manager.show_warning(warning_type)

func hide_warning(warning_type:WarningManager.WarningType) -> void:
	_warning_manager.hide_warning(warning_type)

func show_custom_error(message:String, id:String) -> void:
	_warning_manager.show_custom_error(message, id)

func hide_custom_error(id:String) -> void:
	_warning_manager.hide_custom_error(id)

#endregion

#region private

func _start_new_chapter() -> void:
	chapter_manager.next_chapter()
	contract_generator.generate_contracts(chapter_manager.current_chapter)
	combat_main.start(player.number_of_fields, card_pool, 3, contract_generator.common_contracts[0])

func _game_over() -> void:
	pass

#endregion

#region setter/getter

func _set_gold(val:int) -> void:
	_gold = val
	gui_main_game.gui_shop_main.update_for_gold(_gold)

func _set_hovered_data(val:ThingData) -> void:
	hovered_data = val
	if hovered_data:
		await Util.create_scaled_timer(DETAIL_TOOLTIP_DELAY).timeout
		if hovered_data:
			show_warning(WarningManager.WarningType.DIALOGUE_THING_DETAIL)
	else:
		hide_warning(WarningManager.WarningType.DIALOGUE_THING_DETAIL)

#endregion

func _on_request_rating_update(val:int) -> void:
	rating.value += val
	await gui_main_game.rating_update_finished
	if rating.value == 0:
		_game_over()
