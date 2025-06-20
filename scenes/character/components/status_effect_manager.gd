class_name StatusEffectManager
extends RefCounted

signal status_effect_updated(status_effects:Array[StatusEffect])

const EFFECTS_PREFIX := "res://scenes/attacks/status_effects/status_effect_"

var status_effects:Array[StatusEffect] = []

var character_owner:Character:get = _get_character_owner

var _weak_character_owner:WeakRef = weakref(null)

func _init(character:Character) -> void:
	_weak_character_owner = weakref(character)

func add_status_effect(status_effect_data:StatusEffectData, stack:int) -> void:
	var existing_same_effect_id := Util.array_find(status_effects, func(effect:StatusEffect) -> bool: return effect.data.id == status_effect_data.id)
	var existing_same_effect:StatusEffect = status_effects[existing_same_effect_id] if existing_same_effect_id >= 0 else null
	if existing_same_effect:
		existing_same_effect.stack += stack
	else:
		var status_effect:StatusEffect = _create_status_effect(status_effect_data, stack)
		status_effects.append(status_effect)
	status_effect_updated.emit(status_effects)

func on_predraw() -> void:
	for status_effect in status_effects:
		await status_effect.handle_predraw()

func on_draw() -> void:
	for status_effect in status_effects:
		if status_effect.data.single_turn:
			remove_status_effect(status_effect.data.id)
		else:
			reduce_status_effect(status_effect.data.id, 1)

func on_bingo(bingo_result:BingoResult) -> void:
	for status_effect in status_effects:
		await status_effect.handle_bingo(bingo_result)

func remove_status_effect(status_effect_id:String) -> void:
	var status_effect:StatusEffect = get_status_effect(status_effect_id)
	if status_effect:
		status_effect.on_cleared()
		status_effects.erase(status_effect)
		status_effect_updated.emit(status_effects)

func reduce_status_effect(status_effect_id:String, amount:int) -> void:
	var status_effect:StatusEffect = get_status_effect(status_effect_id)
	status_effect.stack -= amount
	if status_effect.stack <= 0:
		remove_status_effect(status_effect_id)
	status_effect_updated.emit(status_effects)

func clear_status_effects() -> void:
	for status_effect in status_effects:
		remove_status_effect(status_effect.data.id)
	status_effect_updated.emit(status_effects)

func has_status_effect(status_effect_id:String) -> bool:
	return Util.array_find(status_effects, func(effect:StatusEffect) -> bool: return effect.data.id == status_effect_id) >= 0

func get_status_effect(status_effect_id:String) -> StatusEffect:
	var index:int = Util.array_find(status_effects, func(effect:StatusEffect) -> bool: return effect.data.id == status_effect_id)
	return status_effects[index] if index >= 0 else null

#region private

func _create_status_effect(status_effect_data:StatusEffectData, stack:int) -> StatusEffect:
	var path := str(EFFECTS_PREFIX, status_effect_data.id, ".gd")
	assert(ResourceLoader.exists(path))
	return load(path).new(status_effect_data, stack, character_owner)

#endregion

#region getters
func _get_character_owner() -> Character:
	return _weak_character_owner.get_ref()
#endregion
