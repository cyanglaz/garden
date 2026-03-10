class_name GUIPlayerStatus
extends HBoxContainer

const ANIMATION_OFFSET := 3

const ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var stack: Label = %Stack
@onready var _good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio
@onready var _bad_animation_audio: AudioStreamPlayer2D = %BadAnimationAudio

var player_status_id:String = ""
var _player_status_data:StatusData = null
var _tooltip_id:String = ""

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_player_status_data(player_status_data:StatusData) -> void:
	_player_status_data = player_status_data
	player_status_id = player_status_data.id
	gui_icon.texture = load(ICON_PREFIX % player_status_data.id)
	stack.text = str(player_status_data.stack)

func play_trigger_animation() -> void:
	match _player_status_data.type:
		StatusData.Type.BAD:
			_bad_animation_audio.play()
		StatusData.Type.GOOD:
			_good_animation_audio.play()
	var original_position:Vector2 = gui_icon.position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(gui_icon, "position", gui_icon.position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(gui_icon, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	gui_icon.has_outline = true
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.THING_DATA, _player_status_data, _tooltip_id, self, GUITooltip.TooltipPosition.RIGHT))

func _on_mouse_exited() -> void:
	gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
