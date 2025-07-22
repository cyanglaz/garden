class_name GUIBallDescription
extends VBoxContainer

const META_ANCHOR_RECT_OFFSET := 4.0

const DEFAULT_NAME_COLOR_OVERRIDE := Constants.COLOR_WHITE

const SYMBOL_DESCRIPTION_SCENE := preload("res://scenes/GUI/shared/descriptions/gui_ball_symbol_description.tscn")
const ATTACK_COUNT_DESCRIPTION_SCENE := preload("res://scenes/GUI/shared/descriptions/gui_ball_attack_count_description.tscn")
const DISPLAY_RULE_SCENE := preload("res://scenes/GUI/shared/descriptions/gui_rule_icon.tscn")
const ATTACK_COUNT_SCENE := preload("res://scenes/GUI/shared/descriptions/gui_attack_count_icon.tscn")

@export var tooltip_position:GUITooltip.TooltipPosition

@onready var _name_label: Label = %NameLabel
@onready var _gui_description_rich_text_label: RichTextLabel = %GUIDescriptionRichTextLabel
@onready var _gui_bingo_ball: GUIBingoBall = %GUIBingoBall
@onready var _type_label: Label = %TypeLabel
@onready var _gui_tooltip_description_saparator: HSeparator = %GUITooltipDescriptionSaparator
@onready var _left_rules_container: HBoxContainer = %LeftRulesContainer
@onready var _right_rules_container: HBoxContainer = %RightRulesContainer

func bind_bingo_ball_data(bingo_ball_data:BingoBallData, _show_comparison:bool) -> void:
	_gui_bingo_ball.bind_bingo_ball(bingo_ball_data)
	_name_label.text = bingo_ball_data.get_formatted_display_name()
	if bingo_ball_data.is_plus:
		_name_label.add_theme_color_override("font_color", Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN)
	else:
		_name_label.add_theme_color_override("font_color", DEFAULT_NAME_COLOR_OVERRIDE)
	match bingo_ball_data.type:
		BingoBallData.Type.ATTACK:
			_type_label.text = "Attack"
		BingoBallData.Type.SKILL:
			_type_label.text = "Skill"
		BingoBallData.Type.STATUS:
			_type_label.text = "Status"
	#_type_label.self_modulate = Util.get_color_for_type(bingo_ball_data.type)
	#_gui_description_rich_text_label.text = bingo_ball_data.get_display_description(show_comparison)

	if _gui_description_rich_text_label.text.is_empty() && _left_rules_container.get_child_count() == 0 && _right_rules_container.get_child_count() == 0:
		_gui_tooltip_description_saparator.hide()
	else:
		_gui_tooltip_description_saparator.show()
	_gui_description_rich_text_label.tooltip_position = tooltip_position

	# Placement rules
	Util.remove_all_children(_left_rules_container)
	var placement_rule:BingoBallData.PlacementRule = bingo_ball_data.placement_rule
	var values:Array = bingo_ball_data.placement_rule_values
	var display_rule:GUIRuleIcon = DISPLAY_RULE_SCENE.instantiate()
	display_rule.tooltip_position = tooltip_position
	_left_rules_container.add_child(display_rule)
	display_rule.bind_placement_rule(placement_rule, values)
	
	Util.remove_all_children(_right_rules_container)
	if bingo_ball_data is EnemyBingoBallData:
		var attack_count_icon:GUIAttackCountIcon = ATTACK_COUNT_SCENE.instantiate()
		_right_rules_container.add_child(attack_count_icon)
		attack_count_icon.update_with_attack_count(bingo_ball_data.attack_ball_count)
		attack_count_icon.tooltip_position = tooltip_position
