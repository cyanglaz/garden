class_name GUIBasicButton
extends PanelContainer

const SHORT_CUT_ICON_SIZE := 16
const SOUND_HOVER := preload("res://resources/sounds/GUI/button_hover.wav")
const SOUND_CLICK := preload("res://resources/sounds/GUI/button_click.wav")

signal pressed()
signal state_updated(state:ButtonState)

enum ActionType {
	PRESSED,
	HOLD,
}

enum ButtonState {
	NORMAL,
	PRESSED,
	HOVERED,
	DISABLED,
	SELECTED,
}

@export var short_cut:String: set = _set_short_cut
@export var action_type:ActionType = ActionType.PRESSED
@export var hold_time := 0.0
@export var button_state:ButtonState = ButtonState.NORMAL: set = _set_button_state
@export var tooltip_description:String
@export var tooltip_position:GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.TOP

@onready var _sound_hover := AudioStreamPlayer2D.new()

var mouse_in:bool

var _holding_start := false
var _hold_time_count := 0.0
var _weak_tooltip:WeakRef = weakref(null)
var _pressing := false

func _ready() -> void:
	add_child(_sound_hover, false, Node.INTERNAL_MODE_BACK)
	_sound_hover.bus = "SFX"
	_sound_hover.stream = _get_hover_sound()
	_sound_hover.volume_db = -5
	_set_short_cut(short_cut)
	gui_input.connect(_on_gui_input)
	_set_button_state(button_state)
	mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _physics_process(delta: float) -> void:
	if button_state == ButtonState.DISABLED:
		return
	if _holding_start:
		_hold_time_count += delta
		if _hold_time_count > hold_time:
			_hold_time_count = 0
			_holding_start = false
			_press_up()

func _on_gui_input(input_event:InputEvent) -> void:
	if button_state == ButtonState.DISABLED:
		return
	if input_event.is_action("select"):
		if input_event.is_pressed():
			button_state = ButtonState.PRESSED
			_press_down()
		else:
			button_state = ButtonState.NORMAL
			_press_up()

func _input(input_event:InputEvent) -> void:
	if button_state == ButtonState.DISABLED:
		return
	_handle_short_cut(input_event)

func _handle_short_cut(input_event:InputEvent) -> void:
	if button_state == ButtonState.DISABLED:
		return
	if short_cut.is_empty():
		return
	match action_type:
		ActionType.PRESSED:
			if _is_short_cut_pressed(input_event):
				_press_down()
		ActionType.HOLD:
			if _is_short_cut_pressed(input_event):
				_holding_start = true
			elif _is_short_cut_released(input_event):
				_holding_start = false
				_hold_time_count = 0

func _setup_tooltip() -> void:
	if !tooltip_description.is_empty():
		var shortcut_string := ""
		if !short_cut.is_empty():
			var action_events := InputMap.action_get_events(short_cut)
			shortcut_string = action_events.front().as_text()
		_weak_tooltip = weakref(Util.display_button_tooltip(tooltip_description, shortcut_string, self, false, tooltip_position))

func _is_short_cut_pressed(input_event:InputEvent) -> bool:
	if _holding_start:
		return false
	if input_event.is_action_pressed(short_cut):
		return true
	return false

func _is_short_cut_released(input_event:InputEvent) -> bool:
	if input_event.is_action_released(short_cut):
		return true
	return false

func _on_mouse_entered():
	mouse_in = true
	if !tooltip_description.is_empty():
		_weak_tooltip = weakref(Util.display_button_tooltip(tooltip_description, short_cut, self, false, tooltip_position))
	if button_state == ButtonState.DISABLED || button_state == ButtonState.SELECTED:
		return
	button_state = ButtonState.HOVERED
	_sound_hover.play()
	
func _on_mouse_exited():
	mouse_in = false
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)
	if button_state == ButtonState.DISABLED || button_state == ButtonState.SELECTED:
		return
	button_state = ButtonState.NORMAL
	
func _press_down():
	if _pressing:
		return
	_pressing = true

func _press_up():
	assert(_pressing, "Button is not pressing")
	_play_click_sound()
	pressed.emit()
	_pressing = false

func _play_click_sound() -> void:
	var stream := _get_click_sound()
	GlobalSoundManager.play_sound(stream, "SFX", -5)

#region setter/getter

func _set_short_cut(val:String) -> void:
	short_cut = val

func _set_button_state(val:ButtonState) -> void:
	button_state = val
	if button_state == ButtonState.DISABLED:
		mouse_default_cursor_shape = Control.CursorShape.CURSOR_ARROW
	else:
		mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND
	state_updated.emit(button_state)

func _get_hover_sound() -> AudioStream:
	return SOUND_HOVER

func _get_click_sound() -> AudioStream:
	return SOUND_CLICK

#endregion
