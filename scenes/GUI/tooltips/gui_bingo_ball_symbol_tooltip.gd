class_name GUIBingoBallSymbolTooltip
extends GUITooltip

const DESCRIPTION_SCENE := preload("res://scenes/GUI/shared/descriptions/gui_ball_symbol_description.tscn")

@onready var _v_box_container: VBoxContainer = %VBoxContainer

func bind_bingo_ball_data(bingo_ball_data:BingoBallData) -> void:
	Util.remove_all_children(_v_box_container)
	var gui_description := DESCRIPTION_SCENE.instantiate()
	_v_box_container.add_child(gui_description)
	gui_description.setup_with_placement_rule(bingo_ball_data.placement_rule, bingo_ball_data.placement_rule_values)
