class_name ToolData
extends ThingData

const TOOL_SCRIPT_PATH := "res://scenes/main_game/tool/tool_scripts/tool_script_%s.gd"

@warning_ignore("unused_signal")
signal request_refresh()
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
	WITHER,
	NIGHTFALL,
	FLIP,
}

enum Type {
	SKILL,
	POWER,
}


@export var energy_cost:int = 1
@export var actions:Array[ActionData]
@export var rarity:int = 0 # -1: temp cards, 0: common, 1: uncommon, 2: rare
@export var specials:Array[Special]
@export var type:Type = Type.SKILL
@export var back_card:ToolData: set = _set_back_card

var front_card:ToolData: get = _get_front_card, set = _set_front_card
var level_data:Dictionary # Data consists wihtin a level
var has_field_action:bool : get = _get_has_field_action
var need_select_field:bool : get = _get_need_select_field
var all_fields:bool : get = _get_all_fields
var cost:int : get = _get_cost
var tool_script:ToolScript : get = _get_tool_script
var turn_energy_modifier:int
var level_energy_modifier:int
var combat_main:CombatMain: get = _get_combat_main, set = _set_combat_main
var has_tooltip:bool: get = _get_has_tooltip
var _weak_combat_main:WeakRef = weakref(null)

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
	need_select_field = other_tool.need_select_field
	turn_energy_modifier = other_tool.turn_energy_modifier
	type = other_tool.type
	level_energy_modifier = other_tool.level_energy_modifier
	name_postfix = other_tool.name_postfix
	_tool_script = null # Refresh tool script on copy
	if other_tool.back_card:
		back_card = other_tool.back_card.get_duplicate()
	else:
		back_card = null

func refresh_for_turn() -> void:
	turn_energy_modifier = 0

func refresh_for_level() -> void:
	level_energy_modifier = 0
	for action:ActionData in actions:
		action.modified_x_value = 0
		action.modified_value = 0

func get_duplicate() -> ToolData:
	var dup:ToolData = ToolData.new()
	dup.copy(self)
	return dup

func get_final_energy_cost() -> int:
	return energy_cost + get_total_energy_modifier()

func get_total_energy_modifier() -> int:
	return turn_energy_modifier + level_energy_modifier

func get_number_of_secondary_cards_to_select() -> int:
	if tool_script && tool_script.number_of_secondary_cards_to_select() > 0:
		return tool_script.number_of_secondary_cards_to_select()
	for action:ActionData in actions:
		if action.need_card_selection:
			return action.get_calculated_value(null)
	return 0

func get_is_random_secondary_card_selection() -> bool:
	for action:ActionData in actions:
		if action.type in ActionData.NEED_CARD_SELECTION:
			if action.value_type == ActionData.ValueType.RANDOM:
				return true
	return false

func get_card_selection_type() -> ActionData.CardSelectionType:
	if tool_script:
		return tool_script.get_card_selection_type()
	for action:ActionData in actions:
		if action.need_card_selection:
			return action.card_selection_type
	return ActionData.CardSelectionType.NON_RESTRICTED

func get_card_selection_custom_error_message() -> String:
	if tool_script:
		return tool_script.get_card_selection_custom_error_message()
	return ""

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
	
func _get_has_field_action() -> bool:
	if type == Type.POWER:
		return false
	if actions.is_empty():
		return tool_script.has_field_action()
	for action:ActionData in actions:
		if action.action_category == ActionData.ActionCategory.FIELD:
			return true
	return false

func _get_need_select_field() -> bool:
	if !_get_has_field_action():
		return false
	if actions.is_empty():
		return tool_script.need_select_field()
	for action:ActionData in actions:
		if action.action_category == ActionData.ActionCategory.FIELD && !action.specials.has(ActionData.Special.ALL_FIELDS):
			return true
	return false

func _get_all_fields() -> bool:
	if !_get_has_field_action():
		return false
	if _get_need_select_field():
		return false
	return true

func _get_description() -> String:
	if type == Type.POWER:
		return MainDatabase.power_database.get_data_by_id(id).description
	return super._get_description()

func _get_combat_main() -> CombatMain:
	return _weak_combat_main.get_ref()

func _set_combat_main(val:CombatMain) -> void:
	if _weak_combat_main.get_ref() == val:
		return
	_weak_combat_main = weakref(val)
	for action:ActionData in actions:
		action.combat_main = val
	combat_main_set.emit(val)
	if back_card:
		back_card.combat_main = val

func _get_has_tooltip() -> bool:
	return !actions.is_empty() || !specials.is_empty()

func _set_back_card(val:ToolData) -> void:
	if !val:
		back_card = null
		return
	back_card = val.get_duplicate()
	if back_card && !specials.has(Special.FLIP):
		specials.append(Special.FLIP)
	if back_card:
		back_card.front_card = self

func _set_front_card(val:ToolData) -> void:
	_weak_front_card = weakref(val)
	if val && !specials.has(Special.FLIP):
		specials.append(Special.FLIP)

func _get_front_card() -> ToolData:
	return _weak_front_card.get_ref()
