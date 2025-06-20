class_name GUIBingoBall
extends PanelContainer

signal hovered(on:bool)

const SHAKE_ANIMATION_OFFSET := 5.0
const NO_SPACE_MESSAGE := "No valid space."
const CLEAR_TIME:float = 0.05

@export var tooltip_position:GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.RIGHT
@export var enable_tooltips := true
@export var warning_tooltip_position:GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.TOP

@onready var _gui_symbol: GUISymbol = %GUISymbol
@onready var _error_audio_player: AudioStreamPlayer2D = %ErrorAudioPlayer
@onready var _background: NinePatchRect = %Background

var _ball_data:BingoBallData: set = _set_ball_data, get = _get_ball_data

var _weak_warning_tooltip:WeakRef = weakref(null)
var _weak_ball_data:WeakRef = weakref(null)

func _ready() -> void:
	_gui_symbol.tooltip_position = tooltip_position
	_gui_symbol.enable_tooltips = enable_tooltips
	_gui_symbol.mouse_entered.connect(func(): hovered.emit(true))
	_gui_symbol.mouse_exited.connect(func(): hovered.emit(false))

func display_no_space_warning_tooltip() -> void:
	if _weak_warning_tooltip.get_ref():
		return
	_weak_warning_tooltip = weakref(Util.display_warning_tooltip(NO_SPACE_MESSAGE, self, false, warning_tooltip_position))

func hide_warning_tooltip() -> void:
	if _weak_warning_tooltip.get_ref():
		_weak_warning_tooltip.get_ref().queue_free()
		_weak_warning_tooltip = weakref(null)

func bind_bingo_ball(bingo_ball:BingoBallData) -> void:
	_ball_data = bingo_ball
	if bingo_ball:
		_gui_symbol.bind_ball_data(bingo_ball)
	_background.region_rect.position = Util.get_bingo_ball_background_region(bingo_ball, false)

func animate_no_space(time:float) -> void:
	_error_audio_player.play()
	var original_position:Vector2 = position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 3:
		tween.tween_property(self, "position", original_position - Vector2(SHAKE_ANIMATION_OFFSET, 0), time/2/2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "position", original_position + Vector2(SHAKE_ANIMATION_OFFSET, 0), time/2/2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	position = original_position

#region getter/setter

func _get_ball_data() -> BingoBallData:
	return _weak_ball_data.get_ref()

func _set_ball_data(val:BingoBallData) -> void:
	_weak_ball_data = weakref(val)

#endregion
