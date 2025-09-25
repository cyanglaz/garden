class_name GUIBoosterPackTooltip
extends GUITooltip

const TYPE_COLORS := {
	ContractData.BoosterPackType.COMMON: Constants.COLOR_GREEN2,
	ContractData.BoosterPackType.RARE: Constants.COLOR_BLUE_3,
	ContractData.BoosterPackType.LEGENDARY: Constants.COLOR_RED_PURPLE1,
}

const CHANCE_COLORS := {
	50: Constants.COLOR_GREEN2,
	10: Constants.COLOR_BLUE_3,
	1: Constants.COLOR_RED_PURPLE1,
}

@onready var title_label: RichTextLabel = %TitleLabel
@onready var total_number_of_cards_label: RichTextLabel = %TotalNumberOfCardsLabel
@onready var common_card_chance_label: RichTextLabel = %CommonCardChanceLabel
@onready var rare_card_chance_label: RichTextLabel = %RareCardChanceLabel
@onready var legendary_card_chance_label: RichTextLabel = %LegendaryCardChanceLabel
@onready var rare_card_base_count_label: RichTextLabel = %RareCardBaseCountLabel

func update_with_booster_pack_type(booster_pack_type:ContractData.BoosterPackType) -> void:

	var booster_pack_name := ContractData.get_booster_pack_name(booster_pack_type)
	var booster_pack_title := Util.get_localized_string("BOOSTER_PACK_TITLE")
	var color := TYPE_COLORS[booster_pack_type] as Color
	title_label.text = booster_pack_title + Util.convert_to_bbc_highlight_text(booster_pack_name, color)
	
	var number_text := Util.convert_to_bbc_highlight_text(str(ContractData.NUMBER_OF_CARDS_IN_BOOSTER_PACK), Constants.COLOR_WHITE)
	total_number_of_cards_label.text = Util.get_localized_string("BOOSTER_PACK_TOTAL_NUMBER_OF_CARDS_TEXT")% number_text
	
	var common_chance := ContractData.BOOSTER_PACK_CARD_CHANCES[booster_pack_type][0] as int
	var rare_chance := ContractData.BOOSTER_PACK_CARD_CHANCES[booster_pack_type][1] as int
	var legendary_chance := ContractData.BOOSTER_PACK_CARD_CHANCES[booster_pack_type][2] as int
	if common_chance > 0:
		common_card_chance_label.show()
		var common_chance_text := str(common_chance) + "%"
		var common_chance_color := _get_chance_color(common_chance)
		common_chance_text = Util.convert_to_bbc_highlight_text(common_chance_text, common_chance_color)
		common_card_chance_label.text = Util.get_localized_string("BOOSTER_PACK_COMMON_CARD_CHANCE_TEXT")% common_chance_text
	else:
		common_card_chance_label.hide()

	if rare_chance > 0:
		rare_card_chance_label.show()
		var rare_chance_text := str(rare_chance) + "%"
		var rare_chance_color := _get_chance_color(rare_chance)
		rare_chance_text = Util.convert_to_bbc_highlight_text(rare_chance_text, rare_chance_color)
		rare_card_chance_label.text = Util.get_localized_string("BOOSTER_PACK_RARE_CARD_CHANCE_TEXT")% rare_chance_text
	else:
		rare_card_chance_label.hide()

	if legendary_chance > 0:
		legendary_card_chance_label.show()
		var legendary_chance_text := str(legendary_chance) + "%"
		var legendary_chance_color := _get_chance_color(legendary_chance)
		legendary_chance_text = Util.convert_to_bbc_highlight_text(legendary_chance_text, legendary_chance_color)
		legendary_card_chance_label.text = Util.get_localized_string("BOOSTER_PACK_LEGENDARY_CARD_CHANCE_TEXT")% legendary_chance_text
	else:
		legendary_card_chance_label.hide()

	var rare_card_base_count := ContractData.BOOSTER_PACK_CARD_BASE_COUNTS[booster_pack_type][1] as int
	if rare_card_base_count > 0:
		rare_card_base_count_label.show()
		rare_card_base_count_label.text = Util.get_localized_string("BOOSTER_PACK_RARE_CARD_BASE_COUNT_TEXT")% rare_card_base_count
	else:
		rare_card_base_count_label.hide()

func _get_chance_color(chance:int) -> Color:
	for key in CHANCE_COLORS.keys():
		if chance >= key:
			return CHANCE_COLORS[key]
	return Constants.COLOR_WHITE
