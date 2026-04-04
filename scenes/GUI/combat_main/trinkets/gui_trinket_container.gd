class_name GUITrinketContainer
extends VBoxContainer

const PLAYER_TRINKET_SCENE := preload("res://scenes/GUI/combat_main/trinkets/gui_player_trinket.tscn")

@export var trinket_spacing:int = 1
@export var number_pre_row:int = 4

func _ready() -> void:
	grow_vertical = Control.GROW_DIRECTION_END

func bind_with_trinket_container(trinket_container:PlayerTrinketsContainer) -> void:
	trinket_container.player_upgrades_updated.connect(_on_trinket_updated.bind(trinket_container))
	trinket_container.request_player_upgrade_hook_animation.connect(_on_player_upgrade_hook_animation_requested)
	_on_trinket_updated(trinket_container)

func _on_trinket_updated(trinket_container:PlayerTrinketsContainer) -> void:
	Util.remove_all_children(self)
	var current_hbox:HBoxContainer = _add_row()
	current_hbox.add_theme_constant_override("separation", trinket_spacing)
	for trinket:PlayerTrinket in trinket_container.get_all_player_upgrades():
		var gui_trinket:GUIPlayerTrinket = PLAYER_TRINKET_SCENE.instantiate()
		current_hbox.add_child(gui_trinket)
		gui_trinket.show_stack = true
		gui_trinket.show_state = true
		gui_trinket.update_with_trinket_data(trinket.data)
		if current_hbox.get_child_count() >= number_pre_row:
			current_hbox = _add_row()

func _add_row() -> HBoxContainer:
	var current_hbox:HBoxContainer = HBoxContainer.new()
	add_child(current_hbox)
	current_hbox.add_theme_constant_override("separation", trinket_spacing)
	move_child(current_hbox, 0)
	return current_hbox

func _on_player_upgrade_hook_animation_requested(id:String) -> void:
	var animating_trinket:GUIPlayerTrinket
	for current_hbox:HBoxContainer in get_children():
		for child in current_hbox.get_children():
			if child is GUIPlayerTrinket && child.trinket_id == id:
				animating_trinket = child
				break
	assert(animating_trinket !=null, "Animating trinket not found")
	animating_trinket.play_trigger_animation()
