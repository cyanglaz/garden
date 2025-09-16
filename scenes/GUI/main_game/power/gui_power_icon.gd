class_name GUIPowerIcon
extends PanelContainer

@onready var _icon: TextureRect = %Icon
@onready var _stack: Label = %Stack

var power_id:String = ""

var _weak_tooltip:WeakRef = weakref(null)
var _weak_power_data:WeakRef = weakref(null)

func _ready() -> void:
	pass
	#mouse_entered.connect(_on_mouse_entered)
	#mouse_exited.connect(_on_mouse_exited)

func setup_with_power_data(power_data:PowerData) -> void:
	power_id = power_data.id
	_weak_power_data = weakref(power_data)
	_icon.texture = load(Util.get_image_path_for_resource_id(power_data.id))
	if power_data.stack > 1:
		_stack.text = str(power_data.stack)
	else:
		_stack.text = ""

func play_trigger_animation() -> void:
	pass

#func _on_mouse_entered() -> void:
#	_weak_tooltip = weakref(Util.display_field_status_tooltip(_weak_field_status_data.get_ref(), self, false, GUITooltip.TooltipPosition.RIGHT, true))

#func _on_mouse_exited() -> void:
#	if _weak_tooltip:
#		_weak_tooltip.get_ref().queue_free()
#		_weak_tooltip = weakref(null)
