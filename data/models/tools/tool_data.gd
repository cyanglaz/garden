class_name ToolData
extends ThingData

const TOOL_SCRIPT_PATH := "res://scenes/main_game/tool/tool_scripts/tool_script_%s.gd"
const SINGLE_COMBAT_SPECIAL_EFFECTS := [SpecialEffect.STASHED]
const SINGLE_USE_SPECIAL_EFFECTS := [SpecialEffect.STASHED]

@warning_ignore("unused_signal")
signal request_refresh(combat_main:CombatMain)
@warning_ignore("unused_signal")
signal combat_main_set(combat_main:CombatMain)
@warning_ignore("unused_signal")
signal adding_to_deck_finished()

const COSTS := {
	-1:0,
	0: 6,
	1: 11,
	2: 19,
}

enum Special {
	COMPOST,
	HANDY,
	NIGHTFALL,
	FLIP_FRONT,
	FLIP_BACK,
	REVERSIBLE,
}

enum Type {
	SKILL,
	POWER,
}

enum SpecialEffect {
	STASHED, # See Stash Tool Card for more details.
}

const INTERACTIVE_SPECIALS := [Special.FLIP_FRONT, Special.FLIP_BACK, Special.REVERSIBLE]

@export var energy_cost:int = 1
@export var actions:Array[ActionData]
@export var rarity:int = 0 # -1: temp cards, 0: common, 1: uncommon, 2: rare
@export var specials:Array[Special] = []
@export var type:Type = Type.SKILL
@export var back_card:ToolData: set = _set_back_card

var front_card:ToolData: get = _get_front_card, set = _set_front_card
var level_data:Dictionary # Data consists wihtin a level
var cost:int : get = _get_cost
var tool_script:ToolScript : get = _get_tool_script
var turn_energy_modifier:int
var level_energy_modifier:int
var has_tooltip:bool: get = _get_has_tooltip
var special_effects:Array[SpecialEffect]

var _weak_front_card:WeakRef = weakref(null)
var _tool_script:ToolScript

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_tool: ToolData = other as ToolData
	energy_cost = other_tool.energy_cost
	actions.clear()
	for action:ActionData in other_tool.actions:
		actions.append(action.get_duplicate())
	rarity = other_tool.rarity
	specials = other_tool.specials.duplicate()
	turn_energy_modifier = other_tool.turn_energy_modifier
	type = other_tool.type
	level_energy_modifier = other_tool.level_energy_modifier
	special_effects = other_tool.special_effects.duplicate()
	name_postfix = other_tool.name_postfix
	_tool_script = null # Refresh tool script on copy
	if other_tool.back_card:
		back_card = other_tool.back_card.get_duplicate()
	else:
		back_card = null

func refresh_ui(combat_main:CombatMain) -> void:
	if front_card:
		front_card.request_refresh.emit(combat_main)
	if back_card:
		back_card.request_refresh.emit(combat_main)
	request_refresh.emit(combat_main)

func refresh_for_turn() -> void:
	if front_card:
		front_card.card_face_refresh_for_turn()
	if back_card:
		back_card.card_face_refresh_for_turn()
	card_face_refresh_for_turn()

func refresh_for_level() -> void:
	if front_card:
		front_card.card_face_refresh_for_level()
	if back_card:
		back_card.card_face_refresh_for_level()
	card_face_refresh_for_level()

func get_duplicate() -> ToolData:
	var dup:ToolData = ToolData.new()
	dup.copy(self)
	return dup

func remove_single_use_special_effects(combat_main:CombatMain) -> void:
	if front_card:
		front_card.card_face_remove_single_use_special_effects()
	if back_card:
		back_card.card_face_remove_single_use_special_effects()
	card_face_remove_single_use_special_effects()
	refresh_ui(combat_main)

func add_specials(effects:Array[SpecialEffect], combat_main:CombatMain) -> void:
	special_effects.append_array(effects)
	if front_card:
		front_card.special_effects.append_array(effects)
	if back_card:
		back_card.special_effects.append_array(effects)
	refresh_ui(combat_main)

func card_face_refresh_for_turn() -> void:
	turn_energy_modifier = 0

func card_face_refresh_for_level() -> void:
	level_energy_modifier = 0
	special_effects = special_effects.filter(func(special_effect:SpecialEffect): return !SINGLE_COMBAT_SPECIAL_EFFECTS.has(special_effect))
	for action:ActionData in actions:
		action.modified_x_value = 0
		action.modified_value = 0
	
func card_face_remove_single_use_special_effects() -> void:
	special_effects = special_effects.filter(func(special_effect:SpecialEffect): return !SINGLE_USE_SPECIAL_EFFECTS.has(special_effect))

func _get_localization_prefix() -> String:
	return "TOOL_"

func get_final_energy_cost() -> int:
	return energy_cost + get_total_energy_modifier()

func get_total_energy_modifier() -> int:
	if special_effects.has(SpecialEffect.STASHED):
		return -energy_cost
	return turn_energy_modifier + level_energy_modifier

func get_number_of_secondary_cards_to_select_from_script() -> int:
	if tool_script && tool_script.number_of_secondary_cards_to_select() > 0:
		return tool_script.number_of_secondary_cards_to_select()
	return 0

func get_is_random_secondary_card_selection_from_script() -> bool:
	if tool_script:
		return tool_script.get_is_random_secondary_card_selection()
	return false

func get_card_selection_type_from_script() -> ActionData.CardSelectionType:
	if tool_script:
		return tool_script.get_card_selection_type()
	return ActionData.CardSelectionType.NON_RESTRICTED

func get_card_selection_custom_error_message() -> String:
	if tool_script:
		return tool_script.get_card_selection_custom_error_message()
	return ""

func reverse(combat_main:CombatMain) -> void:
	assert(specials.has(Special.REVERSIBLE), "Card is not reversible")
	for action:ActionData in actions:
		if action.type == ActionData.ActionType.PUSH_LEFT:
			action.type = ActionData.ActionType.PUSH_RIGHT
		elif action.type == ActionData.ActionType.PUSH_RIGHT:
			action.type = ActionData.ActionType.PUSH_LEFT
	refresh_ui(combat_main)

func _get_cost() -> int:
	return COSTS[rarity]

func _get_tool_script() -> ToolScript:
	if _tool_script:
		return _tool_script
	var script_path := TOOL_SCRIPT_PATH % [id]
	if ResourceLoader.exists(script_path):
		_tool_script = load(script_path).new()
		return _tool_script
	else:
		return null
	
func get_raw_description() -> String:
	if type == Type.POWER:
		return MainDatabase.player_status_database.get_data_by_id(id).get_raw_description()
	return super.get_raw_description()

func _get_has_tooltip() -> bool:
	return !actions.is_empty() || !specials.is_empty()

func _set_back_card(val:ToolData) -> void:
	if !val:
		back_card = null
		return
	back_card = val.get_duplicate()
	if back_card && !specials.has(Special.FLIP_FRONT):
		specials.erase(Special.FLIP_BACK)
		specials.erase(Special.FLIP_FRONT)
		specials.append(Special.FLIP_FRONT)
	if back_card:
		back_card.front_card = self

func _set_front_card(val:ToolData) -> void:
	_weak_front_card = weakref(val)
	if val && !specials.has(Special.FLIP_BACK):
		specials.erase(Special.FLIP_FRONT)
		specials.erase(Special.FLIP_BACK)
		specials.append(Special.FLIP_BACK)

func _get_front_card() -> ToolData:
	return _weak_front_card.get_ref()
