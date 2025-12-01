class_name GUIPlantAbilityIcon
extends GUIIcon

const INACTIVE_BLEND_COLOR := Constants.COLOR_BLACK

const ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_"

const ANIMATION_OFFSET := 3

@onready var _good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio

var ability_id:String
var active:bool = true: set = _set_active
var library_mode := false
var display_mode := false

var _tooltip_id:String = ""

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_set_active(active)
	
func update_with_plant_ability_id(id:String) -> void:
	ability_id = id
	texture = load(ICON_PATH + ability_id + ".png")

func play_trigger_animation() -> void:
	_good_animation_audio.play()
	var original_position:Vector2 = position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(self, "position", position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
func _on_mouse_entered() -> void:
	is_highlighted = true
	var data := MainDatabase.plant_ability_database.get_data_by_id(ability_id)
	if !library_mode:
		Events.update_hovered_data.emit(data)
	if display_mode:
		return
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.PLANT_ABILITY, data, _tooltip_id, self, GUITooltip.TooltipPosition.BOTTOM_LEFT, {"active":active}))

func _on_mouse_exited() -> void:
	is_highlighted = false
	if !library_mode:
		Events.update_hovered_data.emit(null)
	if display_mode:
		return
	Events.request_hide_tooltip.emit(_tooltip_id)

func _set_active(val:bool) -> void:
	active = val
	if display_mode || library_mode:
		return
	if active:
		material.set_shader_parameter("blend_color", Constants.COLOR_WHITE)
		material.set_shader_parameter("blend_strength", 0.0)
		default_blend_strength = 0.0
	else:
		material.set_shader_parameter("blend_color", INACTIVE_BLEND_COLOR)
		default_blend_strength = 0.7
