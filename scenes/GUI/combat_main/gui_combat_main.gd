class_name GUICombatMain
extends CanvasLayer

signal end_turn_button_pressed()
signal tool_selected(tool_data:ToolData)
signal plant_seed_drawn_animation_completed(plant_data:PlantData)
signal card_use_button_pressed(tool_data:ToolData)
signal mouse_exited_card(tool_data:ToolData)
signal reward_finished(tool_data:ToolData, from_global_position:Vector2)

@onready var gui_weather_container: GUIWeatherContainer = %GUIWeatherContainer
@onready var gui_tool_card_container: GUIToolCardContainer = %GUIToolCardContainer
@onready var gui_draw_box_button: GUIDeckButton = %GUIDrawBoxButton
@onready var gui_discard_box_button: GUIDeckButton = %GUIDiscardBoxButton
@onready var gui_exhaust_box_button: GUIDeckButton = %GUIExhaustBoxButton
@onready var gui_power_container: GUIPowerContainer = %GUIPowerContainer
@onready var gui_boost_tracker: GUIBoostTracker = %GUIBoostTracker
@onready var gui_energy_tracker: GUIEnergyTracker = %GUIEnergyTracker
@onready var end_turn_button: GUIRichTextButton = %EndTurnButton
@onready var gui_enemy: GUIEnemy = %GUIEnemy
@onready var gui_reward_main: GUIRewardMain = %GUIRewardMain

@onready var gui_plant_deck_box: GUIPlantDeckBox = %GUIPlantDeckBox
@onready var gui_plant_seed_animation_container: GUIPlantSeedAnimationContainer = %GUIPlantSeedAnimationContainer

var _toggle_ui_semaphore := 0
var _ui_perm_lock := false

func _ready() -> void:
	end_turn_button.pressed.connect(func() -> void: end_turn_button_pressed.emit())
	gui_tool_card_container.tool_selected.connect(func(tool_data:ToolData) -> void: tool_selected.emit(tool_data))
	gui_tool_card_container.card_use_button_pressed.connect(func(tool_data:ToolData) -> void: card_use_button_pressed.emit(tool_data))
	gui_tool_card_container.setup(gui_draw_box_button, gui_discard_box_button)
	gui_tool_card_container.mouse_exited_card.connect(func(tool_data:ToolData) -> void: mouse_exited_card.emit(tool_data))
	gui_plant_seed_animation_container.draw_plant_card_completed.connect(func(plant_data:PlantData) -> void: plant_seed_drawn_animation_completed.emit(plant_data))
	gui_reward_main.reward_finished.connect(func(tool_data:ToolData, from_global_position:Vector2) -> void: reward_finished.emit(tool_data, from_global_position))

#region power

func bind_power_manager(power_manager:PowerManager) -> void:
	gui_power_container.bind_with_power_manager(power_manager)

#endregion

#region enemy

func update_with_contract(contract:ContractData, combat_main:CombatMain) -> void:
	gui_enemy.update_with_contract(contract, combat_main)

func apply_boss_actions(hook_type:GUIBoss.HookType) -> void:
	await gui_enemy.apply_boss_actions(hook_type)

#endregion

#region plants

func update_with_plants(plants:Array[PlantData]) -> void:
	gui_plant_deck_box.update_with_plants(plants)

func update_mouse_plant(plant:Plant) -> void:
	gui_tool_card_container.update_mouse_plant(plant)

#endregion

#region all ui

func permanently_lock_all_ui() -> void:
	_ui_perm_lock = true
	_toggle_ui(false)

func toggle_all_ui(on:bool) -> void:
	if _ui_perm_lock:
		return
	if on:
		_toggle_ui_semaphore -= 1
	else:
		_toggle_ui_semaphore += 1
	assert(_toggle_ui_semaphore >= 0)
	var toggle_on := false
	if _toggle_ui_semaphore > 0:
		toggle_on = false
	else:
		toggle_on = true
	_toggle_ui(toggle_on)

func _toggle_ui(on:bool) -> void:
	gui_tool_card_container.toggle_all_tool_cards(on)
	if on:
		end_turn_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		end_turn_button.button_state = GUIBasicButton.ButtonState.DISABLED


#region tools
func update_tools(tool_datas:Array[ToolData]) -> void:
	gui_tool_card_container.update_tools(tool_datas)

func clear_tool_selection() -> void:
	gui_tool_card_container.clear_selection()

func bind_tool_deck(tool_deck:Deck) -> void:
	gui_draw_box_button.bind_deck(tool_deck)
	gui_discard_box_button.bind_deck(tool_deck)
	gui_exhaust_box_button.bind_deck(tool_deck)
	gui_draw_box_button.pressed.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_DRAW_POOL_TITLE"), gui_draw_box_button.type))
	gui_discard_box_button.pressed.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_DISCARD_POOL_TITLE"), gui_discard_box_button.type))
	gui_exhaust_box_button.pressed.connect(_on_deck_button_pressed.bind(tool_deck, tr("DECK_EXHAUST_POOL_TITLE"), gui_exhaust_box_button.type))
#endregion


#region plants
func setup_plant_seed_animation_container(plant_field_container:PlantFieldContainer) -> void:
	gui_plant_seed_animation_container.setup(plant_field_container, gui_plant_deck_box)

#endregion

#region energy

func bind_energy(resource_point:ResourcePoint) -> void:
	gui_energy_tracker.bind_with_resource_point(resource_point)

#region weathers
func update_weathers(weather_manager:WeatherManager) -> void:
	gui_weather_container.update_with_weather_manager(weather_manager)

#endregion

#region boost

func update_boost(boost:int) -> void:
	gui_boost_tracker.update_boost(boost)

#endregion

#region penalty

func update_penalty_rate(val:int) -> void:
	gui_enemy.update_penalty(val)

#endregion

#region reward

func animate_show_reward_main(contract_data:ContractData) -> void:
	await gui_reward_main.show_with_contract_data(contract_data)

#endregion

#region events

func _on_deck_button_pressed(deck:Deck, title:String, type: GUIDeckButton.Type) -> void:
	var cards:Array
	match type:
		GUIDeckButton.Type.DRAW:
			cards = deck.draw_pool
		GUIDeckButton.Type.DISCARD:
			cards = deck.discard_pool
		GUIDeckButton.Type.ALL:
			cards = deck.pool
		GUIDeckButton.Type.EXHAUST:
			cards = deck.exhaust_pool
	Events.request_view_cards.emit(cards, title)

#endregion
