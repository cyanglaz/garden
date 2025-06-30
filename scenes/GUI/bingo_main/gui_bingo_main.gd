class_name GUIBingoMain
extends Control

signal draw_button_evoked()
signal power_button_evoked(power_data:PowerData)

@onready var gui_animation_container: GUIAnimationContainer = %GUIAnimationContainer
@onready var _gui_bingo_board: GUIBingoBoard = %GUIBingoBoard
@onready var _gui_bingo_ball_hand: GUIBingoBallHand = %GUIBingoBallHand
@onready var _draw_button: GUIRichTextButton = %DrawButton
@onready var _gui_player_box: GUIPlayerBox = %GUIPlayerBox
@onready var _gui_draw_box_button: GUIDeckButton = %GUIDrawBoxButton
@onready var _gui_draw_pile_display: GUIPileDisplay = %GUIDrawPileDisplay
@onready var _gui_discard_box_button: GUIDeckButton = %GUIDiscardBoxButton
@onready var _gui_discard_pile_display: GUIPileDisplay = %GUIDiscardPileDisplay
@onready var _gui_enemy_container: GUIEnemyContainer = %GUIEnemyContainer
@onready var _gui_following_symbol: GUIFollowingSymbol = %GUIFollowingSymbol
@onready var _gui_power_tooltip: GUIPowerTooltip = %GUIPowerTooltip
@onready var _auto_draw_button: GUIBasicToggleButton = %AutoDrawButton
@onready var _gui_power_button_box: GUIPowerButtonBox = %GUIPowerButtonBox

var auto_draw := false

func _ready() -> void:
	_draw_button.action_evoked.connect(_on_draw_button_evoked)
	_auto_draw_button.toggled.connect(_on_auto_draw_button_toggled)
	_gui_following_symbol.bind_bingo_board(_gui_bingo_board)
	_gui_power_button_box.power_button_evoked.connect(func(power_data:PowerData) : power_button_evoked.emit(power_data))
	gui_animation_container.setup(self)
	_gui_power_tooltip.hide()
	_gui_power_tooltip.sticky = true

func _input(event: InputEvent) -> void:
	# For testing
	if event.is_action_pressed("toggle_auto_draw"):
		_auto_draw_button.visible = !_auto_draw_button.visible

func animate_show() -> void:
	show()

func bind_player(player:Character) -> void:
	_gui_player_box.bind_character(player)
	_gui_draw_box_button.bind_draw_box(player.draw_box)
	_gui_discard_box_button.bind_draw_box(player.draw_box)
	_gui_bingo_ball_hand.setup_draw_box(_gui_draw_box_button)
	_gui_draw_box_button.action_evoked.connect(_on_draw_box_button_evoked.bind(player))
	_gui_discard_box_button.action_evoked.connect(_on_discard_box_button_evoked.bind(player))
	_gui_power_button_box.bind_player(player)

func update_power_cd() -> void:
	handle_power_update()

func handle_power_update() -> void:
	_gui_power_button_box.handle_cd_update()

func refresh_with_board(bingo_board:BingoBoard, animated:bool = false) -> void:
	await _gui_bingo_board.refresh_with_board(bingo_board.board, animated)

func refresh_spaces_for_bingo(bingo_board:BingoBoard, bingo_results:Array[BingoResult]) -> void:
	await _gui_bingo_board.refresh_spaces_for_bingo(bingo_board.board, bingo_results)

func clear_bingo_ball_warnings() -> void:
	_gui_enemy_container.clear_warnings()

func toggle_buttons(enabled:bool) -> void:
	_draw_button.button_state = GUIBasicButton.ButtonState.NORMAL if enabled else GUIBasicButton.ButtonState.DISABLED
	_gui_power_button_box.toggle_enabled(enabled)

#region Events

func _on_draw_button_evoked() -> void:
	draw_button_evoked.emit()

func _on_draw_box_button_evoked(player:Character) -> void:
	_gui_draw_pile_display.visible = !_gui_draw_pile_display.visible
	_gui_draw_pile_display.update_with_pool(player.draw_box.draw_pool)

func _on_discard_box_button_evoked(player:Character) -> void:
	_gui_discard_pile_display.visible = !_gui_discard_pile_display.visible
	_gui_discard_pile_display.update_with_pool(player.draw_box.discard_pool)

func _on_auto_draw_button_toggled(on:bool) -> void:
	auto_draw = on
	if on:
		_on_draw_button_evoked()


#endregion
