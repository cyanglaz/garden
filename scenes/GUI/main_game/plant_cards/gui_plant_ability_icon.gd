class_name GUIPlantAbilityIcon
extends GUIIcon

const ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_"

const ANIMATION_OFFSET := 3

@onready var _good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio

var ability_id:String
var library_mode := false
var display_mode := false

var _weak_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
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
		Singletons.main_game.hovered_data = data
	if display_mode:
		return
	_weak_tooltip = weakref(Util.display_thing_data_tooltip(data, self, false, GUITooltip.TooltipPosition.LEFT, true))
	_weak_tooltip.get_ref().library_tooltip_position = GUITooltip.TooltipPosition.BOTTOM_RIGHT

func _on_mouse_exited() -> void:
	is_highlighted = false
	if !library_mode:
		Singletons.main_game.hovered_data = null
	if display_mode:
		return
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)
