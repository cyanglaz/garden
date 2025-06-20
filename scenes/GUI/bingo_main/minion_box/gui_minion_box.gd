class_name GUIMinionBox
extends PanelContainer

const MINION_ATTACK_BAR_SCENE := preload("res://scenes/GUI/bingo_main/character_boxes/components/gui_minion_attack_bar.tscn")

@onready var _v_box_container: VBoxContainer = %VBoxContainer

var _weak_minion_manager:WeakRef = weakref(null)
var _attack_bars:Dictionary = {}

func bind_with_minion_manager(minion_manager:MinionManager) -> void:
	_weak_minion_manager = weakref(minion_manager)
	minion_manager.bind_ui(self)
	minion_manager.minions_updated.connect(_on_minions_updated)
	_on_minions_updated()

func get_attack_bars() -> Dictionary:
	return _attack_bars

func animate_update_attack_counters(attack_counters:Dictionary, time:float = 0.2) -> void:
	for id:String in attack_counters.keys():
		var attack_counter:ResourcePoint = attack_counters[id]
		animate_update_attack_counter(id, attack_counter, time)

func animate_update_attack_counter(id:String, attack_counter:ResourcePoint, time:float) -> void:
	_attack_bars[id].animate_value_update(attack_counter, time)

func _on_minions_updated() -> void:
	Util.remove_all_children(_v_box_container)
	var minion_datas:Array[BingoBallData] = _weak_minion_manager.get_ref().minion_datas
	var attack_counters:Dictionary = _weak_minion_manager.get_ref().attack_counters
	for minion_data:BingoBallData in minion_datas:
		var counter:ResourcePoint = attack_counters[minion_data.id]
		var gui_minion_attack_bar:GUIAttackBar = MINION_ATTACK_BAR_SCENE.instantiate()
		_v_box_container.add_child(gui_minion_attack_bar)
		gui_minion_attack_bar.bind_ball_data(minion_data, counter)
		_attack_bars[minion_data.id] = gui_minion_attack_bar
