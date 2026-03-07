class_name GUIPlayerTrinket
extends PanelContainer

const ANIMATION_OFFSET := 3

const ICON_PREFIX := "res://resources/sprites/GUI/icons/trinkets/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var stack: Label = %Stack
@onready var good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio

var _tooltip_id:String = ""
var _trinket_data:TrinketData = null
var trinket_id:String = ""

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_trinket_data(trinket_data:TrinketData) -> void:
	_trinket_data = trinket_data
	trinket_id = trinket_data.id
	gui_icon.texture = load(ICON_PREFIX % trinket_data.id)
	if trinket_data.stack > 0:
		stack.text = str(trinket_data.stack)
	else:
		stack.text = ""

func play_trigger_animation() -> void:
	good_animation_audio.play()
	var original_position:Vector2 = gui_icon.position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(gui_icon, "position", gui_icon.position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(gui_icon, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	gui_icon.has_outline = true
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.THING_DATA, _trinket_data, _tooltip_id, self, GUITooltip.TooltipPosition.TOP_RIGHT))

func _on_mouse_exited() -> void:
	gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
