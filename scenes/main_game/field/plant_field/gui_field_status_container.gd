class_name GUIFieldStatusContainer
extends VBoxContainer

const STATUS_ICON_SCENE := preload("res://scenes/main_game/field/plant_field/gui_field_status_icon.tscn")

func bind_with_field_status_container(field_status_container:FieldStatusContainer) -> void:
	field_status_container.status_updated.connect(_on_status_updated.bind(field_status_container))
	field_status_container.request_status_hook_animation.connect(_on_status_hook_animation_requested)
	_on_status_updated(field_status_container)

func _on_status_updated(field_status_container:FieldStatusContainer) -> void:
	Util.remove_all_children(self)
	for field_status:FieldStatus in field_status_container.get_all_statuses():
		var status_icon:GUIFieldStatusIcon = STATUS_ICON_SCENE.instantiate()
		add_child(status_icon)
		status_icon.setup_with_field_status_data(field_status.status_data, field_status.stack)
	
func _on_status_hook_animation_requested(status_id:String) -> void:
	var animating_icon:GUIFieldStatusIcon
	for status_icon:GUIFieldStatusIcon in get_children():
		if status_icon.status_id == status_id:
			animating_icon = status_icon
	assert(animating_icon !=null, "Animating icon not found")
	animating_icon.play_trigger_animation()
