class_name GUIPlayerTrinket
extends PanelContainer

const ANIMATION_OFFSET := 3

const ICON_PREFIX := "res://resources/sprites/GUI/icons/trinkets/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon
@onready var stack: Label = %Stack
@onready var good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio
@onready var collect_sound: AudioStreamPlayer2D = %CollectSound

var _tooltip_id:String = ""
var _trinket_data:TrinketData = null
var trinket_id:String = ""
var tooltip_position: GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.TOP_RIGHT
var show_stack: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_trinket_data(trinket_data:TrinketData) -> void:
	if _trinket_data != null:
		if _trinket_data.stack_changed.is_connected(_refresh_stack):
			_trinket_data.stack_changed.disconnect(_refresh_stack)
		if _trinket_data.state_changed.is_connected(_on_state_changed):
			_trinket_data.state_changed.disconnect(_on_state_changed)
	_trinket_data = trinket_data
	trinket_id = trinket_data.id
	gui_icon.texture = load(ICON_PREFIX % trinket_data.id)
	_refresh_stack(trinket_data.stack)
	_on_state_changed(trinket_data.state)
	if show_stack:
		trinket_data.stack_changed.connect(_refresh_stack)
	trinket_data.state_changed.connect(_on_state_changed)

func _refresh_stack(new_value: int) -> void:
	stack.text = str(new_value) if show_stack and new_value > 0 else ""

func _on_state_changed(new_state: TrinketData.TrinketState) -> void:
	match new_state:
		TrinketData.TrinketState.ACTIVE:
			gui_icon.set_outline_color(Constants.COLOR_YELLOW1)
			gui_icon.has_outline = true
			gui_icon.modulate = Color.WHITE
		TrinketData.TrinketState.DISABLED:
			gui_icon.set_outline_color(Color.WHITE)
			gui_icon.has_outline = false
			gui_icon.modulate = Constants.COLOR_GRAY2
		TrinketData.TrinketState.NORMAL:
			gui_icon.set_outline_color(Color.WHITE)
			gui_icon.has_outline = false
			gui_icon.modulate = Color.WHITE

	# If the mouse is currently hovering this trinket and the new state is not ACTIVE,
	# re-apply the hover outline. This handles state changes that occur while hovering,
	# since _on_mouse_entered() will not be called again until the cursor leaves and re-enters.
	if get_global_rect().has_point(get_global_mouse_position()) \
			and new_state != TrinketData.TrinketState.ACTIVE:
		gui_icon.has_outline = true
func play_trigger_animation() -> void:
	good_animation_audio.play()
	var original_position:Vector2 = gui_icon.position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(gui_icon, "position", gui_icon.position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(gui_icon, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func play_collect_sound() -> void:
	collect_sound.play()

func _on_mouse_entered() -> void:
	if _trinket_data == null:
		return
	if _trinket_data.state != TrinketData.TrinketState.ACTIVE:
		gui_icon.has_outline = true
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.THING_DATA, _trinket_data, _tooltip_id, self, tooltip_position))

func _on_mouse_exited() -> void:
	if _trinket_data == null or _trinket_data.state != TrinketData.TrinketState.ACTIVE:
		gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
