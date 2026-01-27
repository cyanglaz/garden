class_name GUIPlayerStatusContainer
extends HBoxContainer

const PLAYER_STATUS_SCENE := preload("res://scenes/GUI/combat_main/player/gui_player_status.tscn")

func bind_with_player_status_container(player_status_container:PlayerStatusContainer) -> void:
	player_status_container.status_updated.connect(_on_status_updated.bind(player_status_container))
	_on_status_updated(player_status_container)

func _on_status_updated(player_status_container:PlayerStatusContainer) -> void:
	Util.remove_all_children(self)
	for player_status:PlayerStatus in player_status_container.get_all_player_statuses():
		var gui_player_status:GUIPlayerStatus = PLAYER_STATUS_SCENE.instantiate()
		add_child(gui_player_status)
		gui_player_status.update_with_player_status_data(player_status.status_data)
