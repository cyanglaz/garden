class_name BingoBallData
extends ThingData

const STATUS_EFFECT_STRING_PREFIX := "Apply "
const STATUS_EFFECT_STRING_SUFFIX := "to the target."

const UNCOMMON_WEIGHT_SCALE := 2
const RARE_WEIGHT_SCALE := 1

enum Rarity {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	ENEMY = 3,
	POWER = 4,
}

enum Team {
	PLAYER,
	ENEMY,
	NONE,
}

enum Type {
	SKILL,
	ATTACK,
	STATUS,
}

enum PlacementRule {
	NONE = -1,
	ALL = 0,
	ROW = 1,
	COLUMN = 2,
	DIAGONAL = 3,
	CORNER = 4,
	CENTER = 5,
	PRIORITIZE_BOTTOM = 6,
	PRIORITIZE_TOP = 7,
	PRIORITIZE_CORNER = 8,
	PRIORITIZE_EDGE = 9,
	PRIORITIZE_CENTER = 10,
	PRIORITIZE_LEFT = 11,
	PRIORITIZE_RIGHT = 12,
}

enum SpecialRule {
	INTRINSIC
}

@export var damage:int
@export var rarity:Rarity
@export var type:Type
@export var trigger_times:int = 1
@export var attack_ball_count:int = 1
@export var placement_rule:PlacementRule
@export var placement_rule_values:Array
@export var special_rules:Array[SpecialRule]

var team:Team:get = _get_team
var ball_script:BingoBallScript:get = _get_ball_script
var owner:Character:set = _set_owner, get = _get_owner
var is_plus:bool:get = _get_is_plus, set = _set_is_plus

var combat_dmg_boost:int

var _ball_script:BingoBallScript
var _weak_owner = weakref(null)

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_bingo_ball_data := other as BingoBallData
	damage = other_bingo_ball_data.damage
	type = other_bingo_ball_data.type
	trigger_times = other_bingo_ball_data.trigger_times
	attack_ball_count = other_bingo_ball_data.attack_ball_count
	placement_rule = other_bingo_ball_data.placement_rule
	placement_rule_values = other_bingo_ball_data.placement_rule_values.duplicate()
	rarity = other_bingo_ball_data.rarity
	_ball_script = _create_ball_script()
	owner = other_bingo_ball_data.owner
	combat_dmg_boost = other_bingo_ball_data.combat_dmg_boost
	highlight_description_keys = other_bingo_ball_data.highlight_description_keys.duplicate()

func get_duplicate() -> BingoBallData:
	var dup:BingoBallData = BingoBallData.new()
	dup.copy(self)
	return dup

func reset_new_combat() -> void:
	combat_dmg_boost = 0

func get_display_description(comparison:bool) -> String:
	if ball_script:
		ball_script.evaluate_for_description()
	var formatted_description := description
	if type == Type.ATTACK && damage > 0:
		formatted_description = _format_damage_text(comparison) + "\n" + formatted_description

	formatted_description = _formate_references(formatted_description, data, func(reference_id:String) -> bool:
		if comparison && is_plus:
			var upgraded_from_data:BingoBallData = _get_upgraded_from_data()
			if upgraded_from_data.data.has(reference_id):
				if upgraded_from_data.data[reference_id] != data[reference_id]:
					return true
		return false
	)
	return formatted_description
	
func get_formatted_display_name() -> String:
	var name := display_name
	if is_plus:
		name += " +"
	return name

func get_weight(game_level:int) -> int:
	var base_weight := 1
	match rarity:
		Rarity.COMMON:
			base_weight = 50
		Rarity.UNCOMMON:
			base_weight = 15 + game_level * UNCOMMON_WEIGHT_SCALE
		Rarity.RARE:
			base_weight = 2 + game_level * RARE_WEIGHT_SCALE
		_:
			assert(false, "Invalid rarity for weight calculation: " + str(rarity))
	return base_weight
#endregion

func _format_damage_text(show_comparison:bool) -> String:
	var attack := Attack.new(null, damage)
	var dmg_text = str(attack.damage)
	dmg_text = Util.convert_to_bbc_highlight_text(dmg_text, _get_comparison_highlight_color(show_comparison, "damage"))
	if trigger_times == 1:
		dmg_text = tr("CARD_DAMAGE_STRING") % dmg_text
	else:
		var trigger_times_text := str(trigger_times)
		trigger_times_text = Util.convert_to_bbc_highlight_text(trigger_times_text, _get_comparison_highlight_color(show_comparison, "trigger_times"))
		dmg_text = tr("CARD_DAMAGE_STRING_MULTIPLE") % [dmg_text, trigger_times_text]
	return dmg_text

func _get_comparison_highlight_color(show_comparison:bool, key:String) -> Color:
	if upgraded_from_id.is_empty():
		return Constants.COLOR_WHITE
	if show_comparison && is_plus:
		var upgraded_from_data:BingoBallData = _get_upgraded_from_data()
		var original_value
		var this_value
		if key.begins_with("data/"):
			original_value = upgraded_from_data.data[key]
			this_value = data[key]
		else:
			original_value = upgraded_from_data.get(key)
			this_value = get(key)
		if this_value != original_value:
			return Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN
	return Constants.COLOR_WHITE

func _get_upgraded_from_data() -> BingoBallData:
	assert(!upgraded_from_id.is_empty(), "upgraded_from_id is empty")
	return MainDatabase.ball_database.get_data_by_id(upgraded_from_id)

func _get_ball_script() -> BingoBallScript:
	if _ball_script:
		return _ball_script
	return _create_ball_script()

func _get_is_plus() -> bool:
	return !upgraded_from_id.is_empty()

func _create_ball_script() -> BingoBallScript:
	var path := Util.get_script_path_for_ball_id(id)
	if ResourceLoader.exists(path):
		_ball_script = load(path).new(self)
	return _ball_script

func _set_owner(value:Character) -> void:
	_weak_owner = weakref(value)

func _get_owner() -> Character:
	return _weak_owner.get_ref()

func _get_team() -> Team:
	if owner is Player:
		return Team.PLAYER
	elif owner is Enemy:
		return Team.ENEMY
	return Team.NONE

func _set_is_plus(_value:bool) -> void:
	assert(false, "is_plus is read only")
