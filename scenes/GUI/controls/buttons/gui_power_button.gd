class_name GUIPowerButton
extends HBoxContainer

const SHORT_CUT_ICON_PREFIX := "res://resources/sprites/icons/shortcuts/icon_short_cut_"

signal action_evoked()
signal cd_full_animation_finished()

const CD_UPDATE_ANIMATION_DURATION:float = 0.05

@export var tooltip_position: GUITooltip.TooltipPosition = GUITooltip.TooltipPosition.TOP_RIGHT

@onready var _gui_power: GUIPower = %GUIPower
@onready var _tooltip_trigger: TextureRect = %TooltipTrigger
@onready var _cd_progress_bar: GUIProgressBar = %CDProgressBar
@onready var _gui_basic_button: GUIBasicButton = %GUIBasicButton
@onready var _cd_label: Label = %CDLabel
@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var _short_cut_icon: TextureRect = %ShortCutIcon

var button_state:GUIBasicButton.ButtonState: set = _set_button_state, get = _get_button_state
var power_id:String
var _power_data:PowerData: get = _get_power_data
var _weak_power_data:WeakRef = weakref(null)
var default_state:GUIBasicButton.ButtonState = GUIBasicButton.ButtonState.NORMAL
var index:int: set = _set_index
var _cd_counter:int = -1

var _weak_gui_power_tooltip:WeakRef = weakref(null)
var _weak_short_cut_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	_tooltip_trigger.mouse_entered.connect(_on_tooltip_trigger_mouse_entered)
	_short_cut_icon.mouse_entered.connect(_on_short_cut_icon_mouse_entered)
	_short_cut_icon.mouse_exited.connect(_on_short_cut_icon_mouse_exited)
	_short_cut_icon.mouse_default_cursor_shape = Control.CURSOR_HELP
	_gui_basic_button.tooltip_position = tooltip_position
	_gui_basic_button.action_evoked.connect(func() : action_evoked.emit())
	_gui_basic_button.state_updated.connect(_on_button_state_updated)
	_cd_progress_bar.step = 1

func bind_power_data(power_data:PowerData) -> void:
	_weak_power_data = weakref(power_data)
	if power_data:
		_gui_power.update_with_power_data(power_data)
		power_id = power_data.id
		_gui_basic_button.button_state = GUIBasicButton.ButtonState.NORMAL
		_cd_progress_bar.show()
		update_cd(power_data.cd_counter)
	else:
		power_id = ""
		_cd_progress_bar.hide()
		_gui_basic_button.button_state = GUIBasicButton.ButtonState.DISABLED
	
func update_cd(target_cd:int) -> void:
	if _cd_counter == target_cd:
		return
	_cd_counter = target_cd
	_cd_progress_bar.max_value = _power_data.cd
	_cd_label.text = str(_power_data.cd_counter, "/", _power_data.cd)
	_cd_progress_bar.animated_set_value(target_cd)
	if _power_data.cd_counter == _power_data.cd:
		default_state = GUIBasicButton.ButtonState.NORMAL
		play_cd_up_animation()
	else:
		default_state = GUIBasicButton.ButtonState.DISABLED
	set_button_state(default_state)

func play_cd_up_animation() -> void:
	_audio_stream_player_2d.play()
	var tween:Tween = Util.create_scaled_tween(self)
	var delay := CD_UPDATE_ANIMATION_DURATION
	var original_tint := _cd_progress_bar.tint_progress
	var flash_times := 1
	for i in flash_times:
		tween.tween_property(_gui_power, "button_state", GUIBasicButton.ButtonState.HOVERED, CD_UPDATE_ANIMATION_DURATION).set_delay(delay/2).set_ease(Tween.EASE_IN)
		tween.tween_property(_cd_progress_bar, "tint_progress", Color.WHITE, CD_UPDATE_ANIMATION_DURATION).set_delay(delay/2).set_ease(Tween.EASE_IN)
		tween.tween_property(_gui_power, "button_state", GUIBasicButton.ButtonState.NORMAL, CD_UPDATE_ANIMATION_DURATION).set_delay(delay).set_ease(Tween.EASE_IN)
		tween.tween_property(_cd_progress_bar, "tint_progress", original_tint, CD_UPDATE_ANIMATION_DURATION).set_delay(delay).set_ease(Tween.EASE_OUT)
		delay += CD_UPDATE_ANIMATION_DURATION
	# final pause 0.1 second
	tween.tween_property(_cd_progress_bar, "tint_progress", original_tint, 0.1).set_delay((flash_times + 1) * CD_UPDATE_ANIMATION_DURATION)
	tween.tween_callback(func():
		cd_full_animation_finished.emit()
	)

func _set_index(val:int) -> void:
	index = val
	_short_cut_icon.texture = load(SHORT_CUT_ICON_PREFIX + str(val+1) + ".png")

func set_button_state(state:GUIBasicButton.ButtonState) -> void:
	_gui_basic_button.button_state = state
	#if power_id.is_empty():
		#state = GUIBasicButton.ButtonState.DISABLED
	#if _disable_overlay:
		#_disable_overlay.visible = false
		#match state:
			#GUIBasicButton.ButtonState.DISABLED:
				#_disable_overlay.visible = true

func _set_button_state(_state:GUIBasicButton.ButtonState) -> void:
	assert(false, "button_state is ready only, use set_button_state instead")

func _get_button_state() -> GUIBasicButton.ButtonState:
	return _gui_basic_button.button_state

func _get_power_data() -> PowerData:
	return _weak_power_data.get_ref()

func _on_tooltip_trigger_mouse_entered() -> void:
	_weak_gui_power_tooltip = weakref(Util.display_power_tooltip(_power_data, _tooltip_trigger, true, tooltip_position))

func _on_short_cut_icon_mouse_entered() -> void:
	var short_cut_text := tr("PC_SHORT_CUT_TOOLTIP") % str("[outline_size=1][color=", Constants.COLOR_WHITE, "]", str(index+1), "[/color][/outline_size]")
	_weak_short_cut_tooltip = weakref(Util.display_rich_text_tooltip(short_cut_text, _short_cut_icon, false, GUITooltip.TooltipPosition.TOP))

func _on_short_cut_icon_mouse_exited() -> void:
	if _weak_short_cut_tooltip.get_ref():
		_weak_short_cut_tooltip.get_ref().queue_free()

func _on_button_state_updated(state:GUIBasicButton.ButtonState) -> void:
	_gui_power.button_state = state
