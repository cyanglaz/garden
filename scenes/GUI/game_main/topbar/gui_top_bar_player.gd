class_name GUITopBarPlayer
extends HBoxContainer

@onready var _gui_top_player_hp: GUITopPlayerHP = %GUITopPlayerHP

func bind_player(player:Player) -> void:
	_gui_top_player_hp.bind_player(player)
