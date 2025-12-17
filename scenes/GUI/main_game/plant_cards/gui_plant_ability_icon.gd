class_name GUIPlantAbilityIcon
extends PanelContainer

const INACTIVE_BLEND_COLOR := Constants.COLOR_BLACK

const ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_"

const ANIMATION_OFFSET := 3

@onready var _good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio
@onready var _stack_label: Label = %StackLabel
@onready var _gui_icon: GUIIcon = %GUIIcon
@onready var _gui_plant_ability_countdown: GUIPlantAbilityCountdown = %GUIPlantAbilityCountdown

var ability_id:String
var library_mode := false
var display_mode := false
var current_stack:int = 0

var _tooltip_id:String = ""

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
func update_with_plant_ability(plant_ability:PlantAbility) -> void:
	update_with_plant_ability_data(plant_ability.ability_data, plant_ability.stack)
	_gui_plant_ability_countdown.setup_with_plant_ability(plant_ability)

func update_with_plant_ability_data(plant_ability_data:PlantAbilityData, stack:int) -> void:
	current_stack = stack
	ability_id = plant_ability_data.id
	_gui_icon.texture = load(ICON_PATH + plant_ability_data.id + ".png")
	if stack > 0:
		_stack_label.text = str(stack)
	else:
		_stack_label.text = ""

func play_trigger_animation() -> void:
	_good_animation_audio.play()
	var original_position:Vector2 = _gui_icon.position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(_gui_icon, "position", _gui_icon.position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(_gui_icon, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
func _on_mouse_entered() -> void:
	_gui_icon.is_highlighted = true
	var data := MainDatabase.plant_ability_database.get_data_by_id(ability_id)
	if !library_mode:
		Events.update_hovered_data.emit(data)
	if display_mode:
		return
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.PLANT_ABILITY, data, _tooltip_id, self, GUITooltip.TooltipPosition.BOTTOM_LEFT, {"stack": current_stack}))

func _on_mouse_exited() -> void:
	_gui_icon.is_highlighted = false
	if !library_mode:
		Events.update_hovered_data.emit(null)
	if display_mode:
		return
	Events.request_hide_tooltip.emit(_tooltip_id)
