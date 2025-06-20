class_name Player
extends Character

signal action_point_changed(new_ap:int)

var action_point:int: set = _set_action_point
var power_manager:PowerManager
var player_data:PlayerData:get = _get_player_data

var draw_modifiers:Dictionary = {}
var draw_box:DrawBox
var _weak_top_hp_bar:WeakRef = weakref(null)

func _init(d:CharacterData) -> void:
	super._init(d)
	draw_box = DrawBox.new(data.initial_balls)
	for ball in draw_box.pool:
		ball.owner = self
	power_manager = PowerManager.new(data)

func bind_top_hp_bar(gui_hp_bar:GUIHPBar) -> void:
	_weak_top_hp_bar = weakref(gui_hp_bar)

func draw_balls(number:int) -> Array[BingoBallData]:
	if number <= 0:
		return []
	return draw_box.draw(number)

func shuffle_draw_box() -> void:
	draw_box.shuffle_box()

func discard_balls() -> void:
	draw_box.discard()

func insert_ball(ball_data:BingoBallData) -> void:
	ball_data.owner = self
	draw_box.insert_ball(ball_data)

func get_intended_draw_count(total_draw_count:int = -1) -> int:
	if total_draw_count != -1:
		return total_draw_count
	var number = mini(data.draw_count, draw_box.pool.size())
	for draw_modifier in draw_modifiers.values():
		number += draw_modifier
	if number < 0:
		number = 0
	return number

#region getters

func _get_player_data() -> PlayerData:
	return data as PlayerData

func _get_top_hp_bar() -> GUIHPBar:
	return _weak_top_hp_bar.get_ref()
	
func _set_action_point(val:int) -> void:
	action_point = val
	action_point_changed.emit(action_point)
#endregion
