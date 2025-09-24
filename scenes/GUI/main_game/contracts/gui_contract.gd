class_name GUIContract
extends PanelContainer

const BOOSTER_PACK_ICON_MAP := {
	ContractData.BoosterPackType.COMMON: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_common.png",
	ContractData.BoosterPackType.RARE: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_rare.png",
	ContractData.BoosterPackType.LEGENDARY: "res://resources/sprites/GUI/icons/booster_packs/icon_booster_pack_legendary.png",
}

const GUI_PLANT_ICON_SCENE := preload("res://scenes/GUI/main_game/plant_cards/gui_plant_icon.tscn")

@onready var plant_container: GridContainer = %PlantContainer
@onready var grace_period_label: Label = %GracePeriodLabel
@onready var penalty_rate_label: Label = %PenaltyRateLabel
@onready var gui_reward_gold: GUIRewardGold = %GUIRewardGold
@onready var gui_reward_rating: GUIRewardRating = %GUIRewardRating
@onready var gui_reward_booster_pack: GUIOutlineIcon = %GUIRewardBoosterPack

var _weak_tooltip:WeakRef = weakref(null)

func update_with_contract_data(contract:ContractData) -> void:
	Util.remove_all_children(plant_container)
	var index := 0
	for plant_data in contract.plants:
		var gui_plant_icon:GUIPlantIcon = GUI_PLANT_ICON_SCENE.instantiate()
		plant_container.add_child(gui_plant_icon)
		gui_plant_icon.update_with_plant_data(plant_data)
		gui_plant_icon.mouse_entered.connect(_on_mouse_entered_plant_icon.bind(index, plant_data))
		gui_plant_icon.mouse_exited.connect(_on_mouse_exited_plant_icon.bind(index))
		index += 1
	grace_period_label.text = Util.get_localized_string("CONTRACT_GRACE_PERIOD_LABEL_TEXT")% contract.grace_period
	grace_period_label.mouse_entered.connect(_on_mouse_entered_grace_period_label)
	grace_period_label.mouse_exited.connect(_on_mouse_exited_grace_period_label)
	penalty_rate_label.text = Util.get_localized_string("CONTRACT_PENALTY_RATE_LABEL_TEXT")% contract.penalty_rate
	penalty_rate_label.mouse_entered.connect(_on_mouse_entered_penalty_rate_label)
	penalty_rate_label.mouse_exited.connect(_on_mouse_exited_penalty_rate_label)
	gui_reward_gold.update_with_value(contract.reward_gold)
	gui_reward_rating.update_with_value(contract.reward_rating)
	gui_reward_booster_pack.texture = load(BOOSTER_PACK_ICON_MAP[contract.reward_booster_pack_type])

func _on_mouse_entered_plant_icon(index:int, plant_data:PlantData) -> void:
	var gui_plant_icon:GUIPlantIcon = plant_container.get_child(index)
	gui_plant_icon.has_outline = true
	_weak_tooltip = weakref(Util.display_plant_tooltip(plant_data, gui_plant_icon, false, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_plant_icon(index:int) -> void:
	var gui_plant_icon:GUIPlantIcon = plant_container.get_child(index)
	gui_plant_icon.has_outline = false
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)

func _on_mouse_entered_grace_period_label() -> void:
	_weak_tooltip = weakref(Util.display_rich_text_tooltip(Util.get_localized_string("CONTRACT_GRACE_PERIOD_TOOL_TIP_TEXT"), grace_period_label, false, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_grace_period_label() -> void:
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)

func _on_mouse_entered_penalty_rate_label() -> void:
	_weak_tooltip = weakref(Util.display_rich_text_tooltip(Util.get_localized_string("CONTRACT_PENALTY_RATE_TOOL_TIP_TEXT"), penalty_rate_label, false, GUITooltip.TooltipPosition.LEFT))

func _on_mouse_exited_penalty_rate_label() -> void:
	if _weak_tooltip.get_ref():
		_weak_tooltip.get_ref().queue_free()
		_weak_tooltip = weakref(null)
