class_name GUICombat
extends PanelContainer

const BOOSTER_PACK_ICON_MAP := {
	CombatData.BoosterPackType.COMMON: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_common.png",
	CombatData.BoosterPackType.RARE: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_rare.png",
	CombatData.BoosterPackType.LEGENDARY: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_legendary.png",
}

const GUI_COMBAT_PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/combats/gui_combat_plant_icon.tscn")

@onready var plant_container: HBoxContainer = %PlantContainer
@onready var type_title_label: Label = %TypeTitleLabel
@onready var type_value_label: Label = %TypeValueLabel
@onready var gui_reward_gold: GUICombatGold = %GUICombatGold
@onready var gui_reward_hp: GUICombatRating = %GUICombatRating
@onready var gui_reward_booster_pack: GUIIcon = %GUIRewardBoosterPack
@onready var gui_combat_total_resources: GUICombatTotalResources = %GUICombatTotalResources
@onready var background: NinePatchRect = %Background
@onready var gui_boss_tooltip: GUIBossTooltip = %GUIBossTooltip
@onready var combat_main: PanelContainer = %CombatMain
@onready var penalty_rate_title_label: Label = %PenaltyRateTitleLabel
@onready var penalty_rate_value_label: Label = %PenaltyRateValueLabel

var _tooltip_id:String = ""
var _weak_combat_data:WeakRef = weakref(null)
var _mouse_in:bool = false
var has_outline:bool = false:set = _set_has_outline

func _ready() -> void:
	penalty_rate_title_label.mouse_entered.connect(_on_mouse_entered_penalty_rate_label)
	penalty_rate_title_label.mouse_exited.connect(_on_mouse_exited_penalty_rate_label)
	gui_reward_booster_pack.mouse_entered.connect(_on_mouse_entered_booster_pack)
	gui_reward_booster_pack.mouse_exited.connect(_on_mouse_exited_booster_pack)
	gui_combat_total_resources.mouse_entered.connect(_on_mouse_entered_total_resources)
	gui_combat_total_resources.mouse_exited.connect(_on_mouse_exited_total_resources)
	gui_reward_gold.mouse_entered.connect(_on_mouse_entered_reward_gold)
	gui_reward_gold.mouse_exited.connect(_on_mouse_exited_reward_gold)
	type_title_label.text = Util.get_localized_string("COMBAT_TYPE_LABEL_TEXT")

func _process(_delta: float) -> void:
	if combat_main.get_global_rect().has_point(get_global_mouse_position()):
		if !_mouse_in:
			_mouse_in = true
			_on_mouse_entered()
	else:
		if _mouse_in:
			_mouse_in = false
			_on_mouse_exited()

func update_with_combat_data(combat:CombatData) -> void:
	_weak_combat_data = weakref(combat)
	if combat.combat_type == CombatData.CombatType.BOSS:
		gui_boss_tooltip.show()
		gui_boss_tooltip.update_with_boss_data(combat.boss_data)
	else:
		gui_boss_tooltip.hide()
	
	var theme_color := Constants.COLOR_WHITE
	
	match combat.combat_type:
		CombatData.CombatType.BOSS:
			type_value_label.text = Util.get_localized_string("COMBAT_TYPE_VALUE_BOSS_TEXT")
			theme_color = Constants.COMBAT_THEME_COLOR_BOSS
		CombatData.CombatType.ELITE:
			type_value_label.text = Util.get_localized_string("COMBAT_TYPE_VALUE_ELITE_TEXT")
			theme_color = Constants.COMBAT_THEME_COLOR_ELITE
		CombatData.CombatType.COMMON:
			type_value_label.text = Util.get_localized_string("COMBAT_TYPE_VALUE_COMMON_TEXT")
			theme_color = Constants.COMBAT_THEME_COLOR_COMMON
	type_value_label.modulate = theme_color
	
	Util.remove_all_children(plant_container)
	var index := 0
	var total_light := 0
	var total_water := 0
	var plant_data_map := _combine_plant_datas(combat.plants)
	for plant_id:String in plant_data_map.keys():
		var count := plant_data_map[plant_id] as int
		var gui_plant_icon:GUICombatPlaintIcon = GUI_COMBAT_PLANT_ICON_SCENE.instantiate()
		plant_container.add_child(gui_plant_icon)
		var plant_data:PlantData = MainDatabase.plant_database.get_data_by_id(plant_id, true)
		gui_plant_icon.update_with_plant_data(plant_data, count)
		gui_plant_icon.gui_plant_icon.mouse_entered.connect(_on_mouse_entered_plant_icon.bind(index, plant_data))
		gui_plant_icon.gui_plant_icon.mouse_exited.connect(_on_mouse_exited_plant_icon.bind(index))
		index += 1
		total_light += plant_data.light * count
		total_water += plant_data.water * count
	gui_combat_total_resources.update(total_light, total_water)

	penalty_rate_title_label.text = Util.get_localized_string("COMBAT_PENALTY_RATE_LABEL_TEXT")
	penalty_rate_value_label.text = str(combat.penalty_rate)
	penalty_rate_value_label.modulate = theme_color
	
	gui_reward_gold.update_with_value(combat.reward_gold)
	if combat.reward_hp > 0:
		gui_reward_hp.update_with_value(combat.reward_hp)
	else:
		gui_reward_hp.hide()
	gui_reward_booster_pack.texture = load(BOOSTER_PACK_ICON_MAP[combat.reward_booster_pack_type])

func _combine_plant_datas(plant_datas:Array[PlantData]) -> Dictionary:
	var checking_array := plant_datas.duplicate()
	var result := {}
	while checking_array.size() > 0:
		var plant_data:PlantData = checking_array.pop_front()
		if result.has(plant_data.id):
			result[plant_data.id] += 1
		else:
			result[plant_data.id] = 1
	return result

func _on_mouse_entered_plant_icon(index:int, plant_data:PlantData) -> void:
	var gui_combat_plant_icon:GUICombatPlaintIcon = plant_container.get_child(index)
	Events.update_hovered_data.emit(plant_data)
	gui_combat_plant_icon.gui_plant_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.PLANT, plant_data, _tooltip_id, gui_combat_plant_icon.gui_plant_icon, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_plant_icon(index:int) -> void:
	var gui_combat_plant_icon:GUICombatPlaintIcon = plant_container.get_child(index)
	Events.update_hovered_data.emit(null)
	gui_combat_plant_icon.gui_plant_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered_penalty_rate_label() -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.RICH_TEXT, Util.get_localized_string("COMBAT_PENALTY_RATE_TOOL_TIP_TEXT"), _tooltip_id, penalty_rate_title_label, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_penalty_rate_label() -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered_booster_pack() -> void:
	gui_reward_booster_pack.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.BOOSTER_PACK, _weak_combat_data.get_ref().reward_booster_pack_type, _tooltip_id, gui_reward_booster_pack, GUITooltip.TooltipPosition.LEFT))
	
func _on_mouse_exited_booster_pack() -> void:
	gui_reward_booster_pack.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered_total_resources() -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.RICH_TEXT, Util.get_localized_string("COMBAT_TOTAL_RESOURCES_TOOL_TIP_TEXT"), _tooltip_id, gui_combat_total_resources, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_total_resources() -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered_reward_gold() -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.RICH_TEXT, Util.get_localized_string("COMBAT_REWARD_GOLD_TOOL_TIP_TEXT"), _tooltip_id, gui_reward_gold, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_reward_gold() -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered() -> void:
	has_outline = true

func _on_mouse_exited() -> void:
	has_outline = false

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if background:
		if has_outline:
			background.material.set_shader_parameter("outline_size", 1)
		else:
			background.material.set_shader_parameter("outline_size", 0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Events.request_hide_tooltip.emit(_tooltip_id)
