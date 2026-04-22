class_name GUIPlayerStatusContainer
extends HBoxContainer

const PLAYER_STATUS_SCENE := preload("res://scenes/GUI/combat_main/player/gui_player_status.tscn")

func bind_with_player_status_container(player_status_container:PlayerStatusContainer) -> void:
	player_status_container.player_upgrades_updated.connect(_on_player_upgrades_updated.bind(player_status_container))
	player_status_container.request_player_upgrade_hook_animation.connect(_on_player_upgrade_hook_animation_requested)
	_on_player_upgrades_updated(player_status_container)

func _on_player_upgrades_updated(player_status_container:PlayerStatusContainer) -> void:
	var existing_icons:Array = get_children()
	for player_status:PlayerStatus in player_status_container.get_all_player_upgrades():
		var existing_icon_index:int = Util.array_find(existing_icons, func(icon:GUIPlayerStatus) -> bool: return icon.player_status_id == player_status.data.id)
		if existing_icon_index == -1:
			var gui_player_status:GUIPlayerStatus = PLAYER_STATUS_SCENE.instantiate()
			add_child(gui_player_status)
			gui_player_status.update_with_player_status_data(player_status.data)
		else:
			var existing_icon:GUIPlayerStatus = existing_icons[existing_icon_index]
			existing_icon.update_with_player_status_data(player_status.data)
	
	for existing_icon:GUIPlayerStatus in existing_icons:
		if Util.array_find(player_status_container.get_all_player_upgrades(), func(player_status:PlayerStatus) -> bool: return player_status.data.id == existing_icon.player_status_id) == -1:
			existing_icon.queue_free()

func _on_player_upgrade_hook_animation_requested(player_upgrade_id:String) -> void:
	var animating_player_status:GUIPlayerStatus
	for player_status:GUIPlayerStatus in get_children():
		if player_status.player_status_id == player_upgrade_id:
			animating_player_status = player_status
	assert(animating_player_status !=null, "Animating player status not found")
	animating_player_status.play_trigger_animation()
