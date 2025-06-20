class_name GUIEnemyBoxDetail
extends GUICharacterBoxDetail

const ATTACK_BAR_SCENE := preload("res://scenes/GUI/bingo_main/character_boxes/components/gui_enemy_attack_bar.tscn")
const ATTACK_BAR_SCENE_SHORT := preload("res://scenes/GUI/bingo_main/character_boxes/components/gui_attack_bar_short.tscn")

@export var short:bool = false

@onready var _attack_bar_container: Control = %AttackBarContainer

var _attack_bars:Dictionary = {}
var _enemy:Enemy: get = _get_enemy
var _weak_enemy:WeakRef = weakref(null)

func bind_character(character:Character) -> void:
	_weak_enemy = weakref(character as Enemy)
	super.bind_character(character)
	Util.remove_all_children(_attack_bar_container)
	var enemy := character as Enemy
	for id:String in enemy.attack_counters.keys():
		var ball_data_index := Util.array_find(enemy.attacks, func(data:BingoBallData) -> bool: return data.id == id)
		var ball_data:BingoBallData = enemy.attacks[ball_data_index]
		var attack_counter:ResourcePoint = enemy.attack_counters[id]
		var attack_bar_scene := ATTACK_BAR_SCENE_SHORT if short else ATTACK_BAR_SCENE
		var attack_bar:GUIAttackBar = attack_bar_scene.instantiate()
		_attack_bar_container.add_child(attack_bar)
		attack_bar.bind_ball_data(ball_data, attack_counter)
		_attack_bars[id] = attack_bar

func get_attack_bingo_ball(bingo_ball_data:BingoBallData) -> GUIBingoBall:
	var attack_bars := _attack_bar_container.get_children()
	var attack_bar:GUIAttackBar = attack_bars[
		Util.array_find(_enemy.attacks, func(data:BingoBallData) -> bool: return data.base_id == bingo_ball_data.base_id)
	]
	return attack_bar._gui_attack_icon._gui_bingo_ball

func clear_warnings() -> void:
	var attack_bars := _attack_bar_container.get_children()
	for attack_bar:GUIAttackBar in attack_bars:
		attack_bar._gui_attack_icon._gui_bingo_ball.hide_warning_tooltip()
	
func animate_update_attack_counters(attack_counters:Dictionary, time:float = 0.2) -> void:
	for id:String in attack_counters.keys():
		var attack_counter:ResourcePoint = attack_counters[id]
		animate_update_attack_counter(id, attack_counter, time)

func animate_update_attack_counter(id:String, attack_counter:ResourcePoint, time:float) -> void:
	await _attack_bars[id].animate_value_update(attack_counter, time)

func show_only_icon() -> void:
	custom_minimum_size = size
	_attack_bar_container.visible = false
	_gui_hp_bar.visible = false
	_status_effects_container.visible = false
	_name_label.visible = false

func show_all() -> void:
	_attack_bar_container.visible = true
	_gui_hp_bar.visible = true
	_status_effects_container.visible = true
	_name_label.visible = true

#region override

func update_status_effects(status_effects:Array[StatusEffect]) -> void:
	super.update_status_effects(status_effects)
	for gui_status_effect:GUIStatusEffect in _status_effects_container.get_children():
		gui_status_effect.tooltip_position = GUITooltip.TooltipPosition.LEFT

#endregion

func _get_enemy() -> Enemy:
	return _weak_enemy.get_ref()
