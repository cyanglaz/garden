class_name GUIEnemyPreviewTooltip
extends GUITooltip

const GUI_ATTACK_ICON_SCENE := preload("res://scenes/GUI/bingo_main/character_boxes/components/gui_attack_icon.tscn")

@onready var _name_label: Label = %NameLabel
@onready var _attack_container: HBoxContainer = %AttackContainer
@onready var _hp_label: Label = %HPLabel

func bind_with_enemy(enemy:Enemy) -> void:
	Util.remove_all_children(_attack_container)
	_name_label.text = enemy.data.display_name
	_hp_label.text = str(enemy.data.max_hp)
	for bingo_ball_data:BingoBallData in enemy.attacks:
		var gui_attack_icon:GUIAttackIcon = GUI_ATTACK_ICON_SCENE.instantiate()
		_attack_container.add_child(gui_attack_icon)
		gui_attack_icon.bind_ball_data(bingo_ball_data)
