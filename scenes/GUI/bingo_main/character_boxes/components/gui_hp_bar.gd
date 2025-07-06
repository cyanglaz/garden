@tool
class_name GUIHPBar
extends PanelContainer

enum TotalDamageLabelPosition {
	LEFT,
	RIGHT
}

@export var total_damage_label_position:TotalDamageLabelPosition = TotalDamageLabelPosition.LEFT
@export var animating_label := true

const GUI_DAMAGE_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/damage_label.tscn")

@onready var _guirp_bar: GUIRPBar = %GUIRPBar

var _weak_total_damage_label:WeakRef = weakref(null)
var _total_damage_value:int = 0

func bind_with_character(character:Character) -> void:
	_guirp_bar.bind_with_rp(character.hp)

func animate_value_hp(hp:ResourcePoint, time:float) -> void:
	await _guirp_bar.animate_value_update(hp, time)

func add_animating_label(hp_change:int, time:float) -> void:
	if !animating_label:
		return
	#var diff:int = new_value - current_value
	var damage_label:DamageLabel = GUI_DAMAGE_LABEL_SCENE.instantiate()
	add_child(damage_label)
	match total_damage_label_position:
		TotalDamageLabelPosition.LEFT:
			damage_label.global_position = _guirp_bar.global_position
		TotalDamageLabelPosition.RIGHT:
			damage_label.global_position = _guirp_bar.global_position + _guirp_bar.size.x * Vector2.RIGHT + 4 * Vector2.LEFT
	var color:Color
	if hp_change > 0:
		color = Constants.HP_RECOVER_COLOR
	else:
		color = Constants.HP_REDUCE_COLOR
	damage_label.animate_show_and_destroy(str(hp_change), -2, 12, time, time*2, color)
	_show_or_update_total_damage_label(hp_change, Constants.COLOR_GRAY1, time)

func _show_or_update_total_damage_label(damage_value:int, color:Color, time:float) -> void:
	_total_damage_value += damage_value
	var text:String
	if _total_damage_value < 0:
		text = str(_total_damage_value)
	elif _total_damage_value > 0:
		text = str("+", _total_damage_value)
	else:
		text = "0"
	if _weak_total_damage_label.get_ref() != null:
		_weak_total_damage_label.get_ref().text = text
	else:
		var damage_label:DamageLabel = GUI_DAMAGE_LABEL_SCENE.instantiate()
		_guirp_bar.add_child(damage_label)
		match total_damage_label_position:
			TotalDamageLabelPosition.LEFT:
				damage_label.global_position = _guirp_bar.global_position
			TotalDamageLabelPosition.RIGHT:
				damage_label.global_position = _guirp_bar.global_position + _guirp_bar.size.x * Vector2.RIGHT + 4 * Vector2.LEFT
		damage_label.animate_show(text, 4, 0, time, color)
		_weak_total_damage_label = weakref(damage_label)

func destroy_total_damage_label() -> void:
	if _weak_total_damage_label.get_ref() == null:
		return
	await _weak_total_damage_label.get_ref().animate_destroy(0.4)
	_weak_total_damage_label = weakref(null)
	_total_damage_value = 0
