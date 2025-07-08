class_name GUIFieldStatusContainer
extends VBoxContainer

const STATUS_ICON_SCENE := preload("res://scenes/main_game/field/gui_field_status_icon.tscn")

func bind_with_field_status_manager(field_status_manager:FieldStatusManager) -> void:
	field_status_manager.status_updated.connect(_on_status_updated.bind(field_status_manager))
	field_status_manager.request_status_hook_animation.connect(_on_status_hook_animation_requested)
	_on_status_updated(field_status_manager)

func _on_status_updated(field_status_manager:FieldStatusManager) -> void:
	Util.remove_all_children(self)
	for status_data:FieldStatusData in field_status_manager.get_all_statuses():
		var status_icon:GUIFieldStatusIcon = STATUS_ICON_SCENE.instantiate()
		add_child(status_icon)
		status_icon.setup_with_field_status_data(status_data)
	
func _on_status_hook_animation_requested(status_id:String) -> void:
	var animating_icon:GUIFieldStatusIcon
	for status_icon:GUIFieldStatusIcon in get_children():
		if status_icon.status_id == status_id:
			animating_icon = status_icon
	assert(animating_icon !=null, "Animating icon not found")
	animating_icon.play_trigger_animation()
