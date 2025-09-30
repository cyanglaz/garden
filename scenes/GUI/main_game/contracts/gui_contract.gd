class_name GUIContract
extends PanelContainer

const BOOSTER_PACK_ICON_MAP := {
	ContractData.BoosterPackType.COMMON: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_common.png",
	ContractData.BoosterPackType.RARE: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_rare.png",
	ContractData.BoosterPackType.LEGENDARY: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_legendary.png",
}

const GUI_CONTRACT_PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/contracts/gui_contract_plant_icon.tscn")

@onready var plant_container: HBoxContainer = %PlantContainer
@onready var grace_period_label: Label = %GracePeriodLabel
@onready var penalty_rate_label: Label = %PenaltyRateLabel
@onready var gui_reward_gold: GUIContractGold = %GUIContractGold
@onready var gui_reward_rating: GUIContractRating = %GUIContractRating
@onready var gui_reward_booster_pack: GUIOutlineIcon = %GUIRewardBoosterPack
@onready var gui_contract_total_resources: GUIContractTotalResources = %GUIContractTotalResources
@onready var background: NinePatchRect = %Background
@onready var gui_boss_tooltip: GUIBossTooltip = %GUIBossTooltip

var _weak_tooltip:WeakRef = weakref(null)
var has_outline:bool = false:set = _set_has_outline

func update_with_contract_data(contract:ContractData) -> void:
	if contract.contract_type == ContractData.ContractType.BOSS:
		gui_boss_tooltip.show()
		gui_boss_tooltip.update_with_boss_data(contract.boss_data)
	else:
		gui_boss_tooltip.hide()
	
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
	grace_period_label.text = Util.get_localized_string("CONTRACT_GRACE_PERIOD_LABEL_TEXT")% contract.grace_period
	grace_period_label.mouse_entered.connect(_on_mouse_entered_grace_period_label)
	grace_period_label.mouse_exited.connect(_on_mouse_exited_grace_period_label)
	penalty_rate_label.text = Util.get_localized_string("CONTRACT_PENALTY_RATE_LABEL_TEXT")% contract.penalty_rate
	penalty_rate_label.mouse_entered.connect(_on_mouse_entered_penalty_rate_label)
	penalty_rate_label.mouse_exited.connect(_on_mouse_exited_penalty_rate_label)
	gui_reward_gold.update_with_value(contract.reward_gold)
	if contract.reward_rating > 0:
		gui_reward_rating.update_with_value(contract.reward_rating)
	else:
		gui_reward_rating.hide()
	gui_reward_booster_pack.texture = load(BOOSTER_PACK_ICON_MAP[contract.reward_booster_pack_type])
	gui_reward_booster_pack.mouse_entered.connect(_on_mouse_entered_booster_pack.bind(contract.reward_booster_pack_type))
	gui_reward_booster_pack.mouse_exited.connect(_on_mouse_exited_booster_pack)

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
	gui_contract_plant_icon.gui_plant_icon.has_outline = true
	_weak_tooltip = weakref(Util.display_plant_tooltip(plant_data, gui_contract_plant_icon.gui_plant_icon, false, GUITooltip.TooltipPosition.BOTTOM_RIGHT))

func _on_mouse_exited_plant_icon(index:int) -> void:
	var gui_contract_plant_icon:GUIContractPlaintIcon = plant_container.get_child(index)
	gui_contract_plant_icon.gui_plant_icon.has_outline = false
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)

func _on_mouse_entered_grace_period_label() -> void:
	_weak_tooltip = weakref(Util.display_rich_text_tooltip(Util.get_localized_string("CONTRACT_GRACE_PERIOD_TOOL_TIP_TEXT"), grace_period_label, false, GUITooltip.TooltipPosition.BOTTOM_RIGHT))

func _on_mouse_exited_grace_period_label() -> void:
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)

func _on_mouse_entered_penalty_rate_label() -> void:
	_weak_tooltip = weakref(Util.display_rich_text_tooltip(Util.get_localized_string("CONTRACT_PENALTY_RATE_TOOL_TIP_TEXT"), penalty_rate_label, false, GUITooltip.TooltipPosition.BOTTOM_RIGHT))

func _on_mouse_exited_penalty_rate_label() -> void:
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)

func _on_mouse_entered_booster_pack(type:ContractData.BoosterPackType) -> void:
	gui_reward_booster_pack.has_outline = true
	_weak_tooltip = weakref(Util.display_booster_pack_tooltip(type, gui_reward_booster_pack, false, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_booster_pack() -> void:
	gui_reward_booster_pack.has_outline = false
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if background:
		if has_outline:
			background.material.set_shader_parameter("outline_size", 1)
		else:
			background.material.set_shader_parameter("outline_size", 0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _weak_tooltip.get_ref():
			_weak_tooltip.get_ref().queue_free()
			_weak_tooltip = weakref(null)
