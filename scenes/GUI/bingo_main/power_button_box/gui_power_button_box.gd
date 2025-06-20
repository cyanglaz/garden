class_name GUIPowerButtonBox
extends PanelContainer

signal power_button_evoked(power_data:BingoBallData)
signal power_button_mouse_entered(power_data:PowerData)
signal power_button_mouse_exited(power_data:PowerData)

const POWER_BUTTON_SCENE:PackedScene = preload("res://scenes/GUI/controls/buttons/gui_power_button.tscn")

@onready var _h_box_container: HBoxContainer = %HBoxContainer

var _power_manager:PowerManager:get = _get_power_manager
var _weak_power_manager:WeakRef = weakref(null)
#var _current_player_energy:int
var _enabled:bool = false

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("power_1"):
		var button:GUIPowerButton = _h_box_container.get_child(0) as GUIPowerButton
		if button && button.button_state != GUIBasicButton.ButtonState.DISABLED:
			_on_power_button_evoked(_power_manager.powers[0])
	elif event.is_action_pressed("power_2"):
		var button:GUIPowerButton = _h_box_container.get_child(1) as GUIPowerButton
		if button && button.button_state != GUIBasicButton.ButtonState.DISABLED:
			_on_power_button_evoked(_power_manager.powers[1])
	elif event.is_action_pressed("power_3"):
		var button:GUIPowerButton = _h_box_container.get_child(2) as GUIPowerButton
		if button && button.button_state != GUIBasicButton.ButtonState.DISABLED:
			_on_power_button_evoked(_power_manager.powers[2])

func toggle_enabled(enabled:bool) -> void:
	_enabled = enabled
	for child:GUIPowerButton in _h_box_container.get_children():
		if enabled:
			child.set_button_state(child.default_state)
		else:
			child.set_button_state(GUIBasicButton.ButtonState.DISABLED)

func bind_player(player:Player) -> void:
	_weak_power_manager = weakref(player.power_manager)
	player.power_manager.updated.connect(_on_power_manager_updated)
	_on_power_manager_updated()

func handle_cd_update() -> void:
	for i in _power_manager.powers.size():
		var power_data:PowerData = _power_manager.powers[i]
		var gui_power_button:GUIPowerButton = _h_box_container.get_child(i) as GUIPowerButton
		var target_cd:int = power_data.cd_counter
		gui_power_button.update_cd(target_cd)

func _get_button_default_state_based_on_energy(energy:int, energy_cost:int) -> GUIBasicButton.ButtonState:
	if energy < energy_cost:
		return GUIBasicButton.ButtonState.DISABLED
	return GUIBasicButton.ButtonState.NORMAL

func _get_power_manager() -> PowerManager:
	return _weak_power_manager.get_ref()

func _on_power_manager_updated() -> void:
	Util.remove_all_children(_h_box_container)
	var index := 0
	for power_data:PowerData in _power_manager.powers:
		var power_button:GUIPowerButton = POWER_BUTTON_SCENE.instantiate()
		_h_box_container.add_child(power_button)
		power_button.bind_power_data(power_data)
		power_button.index = index
		power_button.action_evoked.connect(_on_power_button_evoked.bind(power_data))
		power_button.mouse_entered.connect(_on_power_button_mouse_entered.bind(power_data))
		power_button.mouse_exited.connect(_on_power_button_mouse_exited.bind(power_data))
		index += 1

func _on_power_button_evoked(power_data:PowerData) -> void:
	if power_data:
		assert(power_data.cd_counter == power_data.cd, "Power button evoked with cd not ready")
		power_button_evoked.emit(power_data)

func _on_power_button_mouse_entered(power_data:PowerData) -> void:
	power_button_mouse_entered.emit(power_data)

func _on_power_button_mouse_exited(power_data:PowerData) -> void:
	power_button_mouse_exited.emit(power_data)
