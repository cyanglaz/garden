class_name GUIPowerContainer
extends GridContainer

const ICON_SCENE := preload("res://scenes/GUI/main_game/power/gui_power_icon.tscn")

func bind_with_power_manager(power_manager:PowerManager) -> void:
	power_manager.power_updated.connect(_on_power_updated.bind(power_manager))
	power_manager.request_power_hook_animation.connect(_on_power_hook_animation_requested)
	_on_power_updated(power_manager)

func _on_power_updated(power_manager:PowerManager) -> void:
	Util.remove_all_children(self)
	for power_data:PowerData in power_manager.get_all_powers():
		var power_icon: GUIPowerIcon = ICON_SCENE.instantiate()
		add_child(power_icon)
		power_icon.setup_with_power_data(power_data)
	
func _on_power_hook_animation_requested(power_id:String) -> void:
	var animating_icon:GUIPowerIcon
	for status_icon:GUIPowerIcon in get_children():
		if status_icon.power_id == power_id:
			animating_icon = status_icon
	assert(animating_icon !=null, "Animating icon not found")
	animating_icon.play_trigger_animation()
