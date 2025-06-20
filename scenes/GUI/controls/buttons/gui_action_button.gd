class_name GUIActionButton
extends GUIBasicButton

signal card_selected(action_data:ActionData)

const NOT_ENOUGH_AP_COLOR := Constants.COLOR_GRAY3
const ICON_PREFIX := "res://resources/sprites/icons/actions/icon_"
const AP_IMAGE_PATH := "res://resources/sprites/icons/other/icon_action_points.png"
var NOT_ENOUGH_AP_MESSAGE := str("[center]Not enough [img=6x6]", AP_IMAGE_PATH, "[/img][/center]")

@onready var title: Label = %Title
@onready var icon: TextureRect = %Icon
@onready var description: Label = %Description
@onready var _gui_action_points: GUIActionPoints = %GUIActionPoints
@onready var _error_message: RichTextLabel = %ErrorMessage
@onready var _error_audio: AudioStreamPlayer2D = %ErrorAudio
@onready var _inner_border: NinePatchRect = %InnerBorder

var _player:Player: get = _get_player
var _action_data:ActionData: get = _get_action_data
var _weak_player:WeakRef = weakref(null)
var _weak_action_data:WeakRef = weakref(null)
var _animating_error:bool = false

func _ready() -> void:
	super._ready()
	action_evoked.connect(_on_action_evoked)

func bind_action_data(action_data:ActionData, player:Player) -> void:
	title.text = action_data.display_name
	icon.texture = load(str(ICON_PREFIX, action_data.id, ".png"))
	_gui_action_points.set_static_ap(action_data.cost)
	description.text = " "
	_error_message.text = " "
	_weak_player = weakref(player)
	_weak_action_data = weakref(action_data)
	refresh()

func handle_show() -> void:
	_set_button_state(ButtonState.NORMAL)
	_error_message.text = " "
	description.text = " "

func refresh() -> void:
	if _player:
		if _player.action_point < _action_data.cost:
			icon.self_modulate = NOT_ENOUGH_AP_COLOR
		else:
			icon.self_modulate = Constants.COLOR_WHITE

func animate_error() -> void:
	_animating_error = true
	_error_audio.play()
	_error_message.text = NOT_ENOUGH_AP_MESSAGE
	description.text = _action_data.get_display_description()
	var tween:Tween = Util.create_scaled_tween(self)
	var initial_position:Vector2 = self.position
	tween.tween_property(self, "position", initial_position + Vector2.RIGHT * 5, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", initial_position - Vector2.RIGHT * 5, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", initial_position, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	_animating_error = false

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	match button_state:
		ButtonState.NORMAL, ButtonState.DISABLED, ButtonState.PRESSED, ButtonState.SELECTED:
			_inner_border.hide()
		ButtonState.HOVERED:
			_inner_border.show()
			if _player.action_point < _action_data.cost:
				_inner_border.self_modulate = Constants.COLOR_GRAY3
			else:
				_inner_border.self_modulate = Constants.COLOR_BLUE_2
	refresh()
		
func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	description.text = _action_data.get_display_description()
	if _player.action_point < _action_data.cost:
		_error_message.text = NOT_ENOUGH_AP_MESSAGE
	else:
		_error_message.text = " "

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	if _animating_error:
		return
	description.text = " "
	_error_message.text = " "

func _get_player() -> Player:
	return _weak_player.get_ref()

func _get_action_data() -> ActionData:
	return _weak_action_data.get_ref()

#region events

func _on_action_evoked() -> void:
	if !_player:
		return
	if _player.action_point >= _action_data.cost:
		card_selected.emit(_action_data)
	else:
		animate_error()

#endregion
