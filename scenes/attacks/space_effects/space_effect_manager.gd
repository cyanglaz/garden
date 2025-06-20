class_name SpaceEffectManager
extends RefCounted

signal space_effect_updated(space_effects:Array[SpaceEffect])

const EFFECTS_PREFIX := "res://scenes/attacks/space_effects/space_effect_"

var space_effects:Array[SpaceEffect] = []

func get_duplicate() -> SpaceEffectManager:
	var dup:SpaceEffectManager = SpaceEffectManager.new()
	for space_effect:SpaceEffect in space_effects:
		dup.add_space_effect(space_effect.data, space_effect.stack)
	return dup

func add_space_effect(space_effect_data:SpaceEffectData, stack:int) -> void:
	var existing_same_effect_id := Util.array_find(space_effects, func(effect:SpaceEffect) -> bool: return effect.data.id == space_effect_data.id)
	var existing_same_effect:SpaceEffect = space_effects[existing_same_effect_id] if existing_same_effect_id >= 0 else null
	if existing_same_effect:
			existing_same_effect.stack += 1
	else:
		var space_effect:SpaceEffect = _create_space_effect(space_effect_data, stack)
		space_effects.append(space_effect)
	space_effect_updated.emit(space_effects)

func remove_space_effect(space_effect_id:String) -> void:
	var space_effect:SpaceEffect = get_space_effect(space_effect_id)
	space_effects.erase(space_effect)
	space_effect_updated.emit(space_effects)

func reduce_space_effect(space_effect_id:String, amount:int) -> void:
	var space_effect:SpaceEffect = get_space_effect(space_effect_id)
	space_effect.stack -= amount
	if space_effect.stack <= 0:
		remove_space_effect(space_effect_id)
	space_effect_updated.emit(space_effects)

func clear_space_effects() -> void:
	space_effects.clear()
	space_effect_updated.emit(space_effects)

func has_space_effect(space_effect_id:String) -> bool:
	return Util.array_find(space_effects, func(effect:SpaceEffect) -> bool: return effect.data.id == space_effect_id) >= 0

func get_space_effect(space_effect_id:String) -> SpaceEffect:
	var index:int = Util.array_find(space_effects, func(effect:SpaceEffect) -> bool: return effect.data.id == space_effect_id)
	return space_effects[index] if index >= 0 else null

func handle_space_effect_bingo_event(bingo_space_data:BingoSpaceData, bingo_result:BingoResult) -> void:
	for space_effect:SpaceEffect in space_effects:
		await space_effect.handle_bingo_event(bingo_space_data, bingo_result)

#region private

func _create_space_effect(space_effect_data:SpaceEffectData, stack:int) -> SpaceEffect:
	var script_path := str(EFFECTS_PREFIX, space_effect_data.id, ".gd")
	assert(ResourceLoader.exists(script_path))
	return load(script_path).new(space_effect_data, stack)

#endregion
