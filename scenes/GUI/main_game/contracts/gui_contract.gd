class_name GUIContract
extends PanelContainer

const BOOSTER_PACK_ICON_MAP := {
	ContractData.BoosterPackType.COMMON: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_common.png",
	ContractData.BoosterPackType.RARE: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_rare.png",
	ContractData.BoosterPackType.LEGENDARY: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_legendary.png",
}

const GUI_CONTRACT_PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/contracts/gui_contract_plant_icon.tscn")

@onready var plant_container: HBoxContainer = %PlantContainer
@onready var type_title_label: Label = %TypeTitleLabel
@onready var type_value_label: Label = %TypeValueLabel
@onready var gui_reward_gold: GUIContractGold = %GUIContractGold
@onready var gui_reward_rating: GUIContractRating = %GUIContractRating
@onready var gui_reward_booster_pack: GUIIcon = %GUIRewardBoosterPack
@onready var gui_contract_total_resources: GUIContractTotalResources = %GUIContractTotalResources
@onready var background: NinePatchRect = %Background
@onready var gui_boss_tooltip: GUIBossTooltip = %GUIBossTooltip
@onready var contract_main: PanelContainer = %ContractMain
@onready var penalty_rate_title_label: Label = %PenaltyRateTitleLabel
@onready var penalty_rate_value_label: Label = %PenaltyRateValueLabel

var _tooltip_id:String = ""
var _weak_contract_data:WeakRef = weakref(null)
var _mouse_in:bool = false
var has_outline:bool = false:set = _set_has_outline

func _ready() -> void:
	penalty_rate_title_label.mouse_entered.connect(_on_mouse_entered_penalty_rate_label)
	penalty_rate_title_label.mouse_exited.connect(_on_mouse_exited_penalty_rate_label)
	gui_reward_booster_pack.mouse_entered.connect(_on_mouse_entered_booster_pack)
	gui_reward_booster_pack.mouse_exited.connect(_on_mouse_exited_booster_pack)
	gui_contract_total_resources.mouse_entered.connect(_on_mouse_entered_total_resources)
	gui_contract_total_resources.mouse_exited.connect(_on_mouse_exited_total_resources)
	gui_reward_gold.mouse_entered.connect(_on_mouse_entered_reward_gold)
	gui_reward_gold.mouse_exited.connect(_on_mouse_exited_reward_gold)
	type_title_label.text = Util.get_localized_string("CONTRACT_TYPE_LABEL_TEXT")

func _process(_delta: float) -> void:
	if contract_main.get_global_rect().has_point(get_global_mouse_position()):
		if !_mouse_in:
			_mouse_in = true
			_on_mouse_entered()
	else:
		if _mouse_in:
			_mouse_in = false
			_on_mouse_exited()

func update_with_contract_data(contract:ContractData) -> void:
	_weak_contract_data = weakref(contract)
	if contract.contract_type == ContractData.ContractType.BOSS:
		gui_boss_tooltip.show()
		gui_boss_tooltip.update_with_boss_data(contract.boss_data)
	else:
		gui_boss_tooltip.hide()
	
	var theme_color := Constants.COLOR_WHITE
	
	match contract.contract_type:
		ContractData.ContractType.BOSS:
			type_value_label.text = Util.get_localized_string("CONTRACT_TYPE_VALUE_BOSS_TEXT")
			theme_color = Constants.CONTRACT_THEME_COLOR_BOSS
		ContractData.ContractType.ELITE:
			type_value_label.text = Util.get_localized_string("CONTRACT_TYPE_VALUE_ELITE_TEXT")
			theme_color = Constants.CONTRACT_THEME_COLOR_ELITE
		ContractData.ContractType.COMMON:
			type_value_label.text = Util.get_localized_string("CONTRACT_TYPE_VALUE_COMMON_TEXT")
			theme_color = Constants.CONTRACT_THEME_COLOR_COMMON
	type_value_label.modulate = theme_color
	
	Util.remove_all_children(plant_container)
	var index := 0
	var total_light := 0
	var total_water := 0
	var plant_data_map := _combine_plant_datas(contract.plants)
	for plant_id:String in plant_data_map.keys():
		var count := plant_data_map[plant_id] as int
		var gui_plant_icon:GUIContractPlaintIcon = GUI_CONTRACT_PLANT_ICON_SCENE.instantiate()
		plant_container.add_child(gui_plant_icon)
		var plant_data:PlantData = MainDatabase.plant_database.get_data_by_id(plant_id, true)
		gui_plant_icon.update_with_plant_data(plant_data, count)
		gui_plant_icon.gui_plant_icon.mouse_entered.connect(_on_mouse_entered_plant_icon.bind(index, plant_data))
		gui_plant_icon.gui_plant_icon.mouse_exited.connect(_on_mouse_exited_plant_icon.bind(index))
		index += 1
		total_light += plant_data.light * count
		total_water += plant_data.water * count
	gui_contract_total_resources.update(total_light, total_water)

	penalty_rate_title_label.text = Util.get_localized_string("CONTRACT_PENALTY_RATE_LABEL_TEXT")
	penalty_rate_value_label.text = str(contract.penalty_rate)
	penalty_rate_value_label.modulate = theme_color
	
	gui_reward_gold.update_with_value(contract.reward_gold)
	if contract.reward_rating > 0:
		gui_reward_rating.update_with_value(contract.reward_rating)
	else:
		gui_reward_rating.hide()
	gui_reward_booster_pack.texture = load(BOOSTER_PACK_ICON_MAP[contract.reward_booster_pack_type])

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
	var gui_contract_plant_icon:GUIContractPlaintIcon = plant_container.get_child(index)
	Events.update_hovered_data.emit(plant_data)
	gui_contract_plant_icon.gui_plant_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.PLANT, plant_data, _tooltip_id, gui_contract_plant_icon.gui_plant_icon, false, GUITooltip.TooltipPosition.LEFT, false)

func _on_mouse_exited_plant_icon(index:int) -> void:
	var gui_contract_plant_icon:GUIContractPlaintIcon = plant_container.get_child(index)
	Events.update_hovered_data.emit(null)
	gui_contract_plant_icon.gui_plant_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered_penalty_rate_label() -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.RICH_TEXT, Util.get_localized_string("CONTRACT_PENALTY_RATE_TOOL_TIP_TEXT"), _tooltip_id, penalty_rate_title_label, false, GUITooltip.TooltipPosition.LEFT, false)

func _on_mouse_exited_penalty_rate_label() -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered_booster_pack() -> void:
	gui_reward_booster_pack.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.BOOSTER_PACK, _weak_contract_data.get_ref().reward_booster_pack_type, _tooltip_id, gui_reward_booster_pack, false, GUITooltip.TooltipPosition.LEFT, false)
	
func _on_mouse_exited_booster_pack() -> void:
	gui_reward_booster_pack.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered_total_resources() -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.RICH_TEXT, Util.get_localized_string("CONTRACT_TOTAL_RESOURCES_TOOL_TIP_TEXT"), _tooltip_id, gui_contract_total_resources, false, GUITooltip.TooltipPosition.LEFT, false)

func _on_mouse_exited_total_resources() -> void:
	Events.request_hide_tooltip.emit(_tooltip_id)

func _on_mouse_entered_reward_gold() -> void:
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.RICH_TEXT, Util.get_localized_string("CONTRACT_REWARD_GOLD_TOOL_TIP_TEXT"), _tooltip_id, gui_reward_gold, false, GUITooltip.TooltipPosition.LEFT, false)

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
