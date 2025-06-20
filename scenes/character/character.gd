class_name Character
extends RefCounted

signal died()
signal hurt(hurt:Damage)

var data:CharacterData
var hp:ResourcePoint = ResourcePoint.new()
var status_effect_manager:StatusEffectManager = StatusEffectManager.new(self)

var is_died:bool = false:set = _set_is_died

var _box:CharacterBox: get = _get_box

var _weak_box:WeakRef = weakref(null)

func _init(d:CharacterData) -> void:
	data = d.get_duplicate()
	hp.setup(data.max_hp, data.max_hp)
	status_effect_manager.status_effect_updated.connect(_on_status_effect_updated)

func bind_box(box:CharacterBox) -> void:
	_weak_box = weakref(box)

func animate_receive_attack(attack:Attack, time:float = 0.2, show_label:bool = true) -> void:
	var hp_change = attack.damage
	hp.spend(mini(hp_change, hp.value))
	await _box.animate_being_attacked(self, -hp_change, time, show_label)
	var damage:Damage = Damage.new(attack.damage, hp_change)
	hurt.emit(damage)
	if hp.value <= 0:
		is_died = true

func animate_restore_hp(hp_change:int, time:float = 0.2, show_label:bool = true) -> void:
	hp.restore(hp_change)
	await _box.animate_restore_hp(self, hp_change, time, show_label)

func end_damage_sequence() -> void:
	_box.end_damage_sequence()

#region getter/setter
func _get_box() -> CharacterBox:
	return _weak_box.get_ref()

func _set_is_died(value:bool) -> void:
	if is_died == value:
		return
	is_died = value
	if is_died:
		died.emit()
#endregion

#region events

func _on_status_effect_updated(status_effects:Array[StatusEffect]) -> void:
	_box.update_status_effects(status_effects)

#endregion
