class_name GUISymbol
extends TextureRect

@export var tooltip_position:GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.RIGHT
@export var enable_tooltips := false

var _ball_data:BingoBallData: set = _set_ball_data, get = _get_ball_data

var _weak_tooltip = weakref(null)
var _weak_ball_data:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)

func bind_ball_data(ball_data:BingoBallData) -> void:
	if !ball_data || ball_data.base_id.is_empty():
		texture = null
		mouse_default_cursor_shape = Control.CursorShape.CURSOR_ARROW
	else:
		texture = load(Util.get_image_path_for_ball_id(ball_data.base_id))
		if enable_tooltips:
			mouse_default_cursor_shape = Control.CursorShape.CURSOR_HELP
	_ball_data = ball_data
	pivot_offset = size/2
	
#region events

func _on_mouse_entered() -> void:
	if !_ball_data:
		return
	if !enable_tooltips:
		return
	if is_instance_valid(_weak_tooltip.get_ref()):
		return
	_weak_tooltip = weakref(Util.display_ball_tooltip(_ball_data, self, true, tooltip_position))

#endregion

#region getter/setter

func _get_ball_data() -> BingoBallData:
	return _weak_ball_data.get_ref()

func _set_ball_data(val:BingoBallData) -> void:
	_weak_ball_data = weakref(val)

#endregion
