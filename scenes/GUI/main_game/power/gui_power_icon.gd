class_name GUIPowerIcon
extends PanelContainer

const ANIMATION_OFFSET := 3

@onready var _icon: TextureRect = %Icon
@onready var _stack: Label = %Stack

var power_id:String = ""
var has_outline:bool = false:set = _set_has_outline

var _weak_tooltip:WeakRef = weakref(null)
var _weak_power_data:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup_with_power_data(power_data:PowerData) -> void:
	power_id = power_data.id
	_weak_power_data = weakref(power_data)
	_icon.texture = load(Util.get_image_path_for_resource_id(power_data.id))
	if power_data.stack > 1:
		_stack.text = str(power_data.stack)
	else:
		_stack.text = ""

func play_trigger_animation() -> void:
	var original_position:Vector2 = _icon.position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(_icon, "position", _icon.position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(_icon, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	_weak_tooltip = weakref(Util.display_thing_data_tooltip(_weak_power_data.get_ref(), self, false, GUITooltip.TooltipPosition.TOP_RIGHT, true))
	_weak_tooltip.get_ref().library_tooltip_position = GUITooltip.TooltipPosition.BOTTOM_RIGHT

func _on_mouse_exited() -> void:
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if has_outline:
		(_icon.material as ShaderMaterial).set_shader_parameter("outline", 1)
	else:
		(_icon.material as ShaderMaterial).set_shader_parameter("outline", 0)
