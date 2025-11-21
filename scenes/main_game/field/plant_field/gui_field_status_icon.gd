class_name GUIFieldStatusIcon
extends PanelContainer

const ANIMATION_OFFSET := 3

@onready var _gui_icon: GUIIcon = %GUIIcon
@onready var _stack: Label = %Stack
@onready var _good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio
@onready var _bad_animation_audio: AudioStreamPlayer2D = %BadAnimationAudio

var status_id:String = ""
var status_type:FieldStatusData.Type
var is_highlighted:bool = false:set = _set_is_highlighted
var display_mode := false: set = _set_display_mode
var library_mode := false

var _tooltip_id:String = ""
var _weak_field_status_data:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup_with_field_status_data(field_status_data:FieldStatusData) -> void:
	_weak_field_status_data = weakref(field_status_data)
	_gui_icon.texture = load(Util.get_image_path_for_resource_id(field_status_data.id))
	if field_status_data.stackable:
		_stack.text = str(field_status_data.stack)
	else:
		_stack.text = ""
	status_id = field_status_data.id
	status_type = field_status_data.type

func play_trigger_animation() -> void:
	match status_type:
		FieldStatusData.Type.BAD:
			_bad_animation_audio.play()
		FieldStatusData.Type.GOOD:
			_good_animation_audio.play()
	var original_position:Vector2 = _gui_icon.position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(_gui_icon, "position", _gui_icon.position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(_gui_icon, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
func _on_mouse_entered() -> void:
	is_highlighted = true
	if !library_mode:
		Events.update_hovered_data.emit(_weak_field_status_data.get_ref())
	if display_mode:
		return
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.THING_DATA, _weak_field_status_data.get_ref(), _tooltip_id, self, GUITooltip.TooltipPosition.BOTTOM_RIGHT))

func _on_mouse_exited() -> void:
	is_highlighted = false
	if !library_mode:
		Events.update_hovered_data.emit(null)
	if display_mode:
		return
	Events.request_hide_tooltip.emit(_tooltip_id)
	
func _set_is_highlighted(val:bool) -> void:
	is_highlighted = val
	if is_highlighted:
		(_gui_icon.material as ShaderMaterial).set_shader_parameter("blend_strength", 0.2)
	else:
		(_gui_icon.material as ShaderMaterial).set_shader_parameter("blend_strength", 0.0)

func _set_display_mode(val:bool) -> void:
	display_mode = val
	_stack.visible = !val
