class_name GUIBoosterPackTooltip
extends GUITooltip

const TYPE_COLORS := {
	ContractData.BoosterPackType.COMMON: Constants.COLOR_GREEN2,
	ContractData.BoosterPackType.RARE: Constants.COLOR_BLUE_3,
	ContractData.BoosterPackType.LEGENDARY: Constants.COLOR_PURPLE1,
}

@onready var title_label: RichTextLabel = %TitleLabel
@onready var total_number_of_cards_label: RichTextLabel = %TotalNumberOfCardsLabel
@onready var common_card_chance_label: RichTextLabel = %CommonCardChanceLabel
@onready var rare_card_chance_label: RichTextLabel = %RareCardChanceLabel
@onready var legendary_card_chance_label: RichTextLabel = %LegendaryCardChanceLabel

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
		var chance_color := TYPE_COLORS[ContractData.BoosterPackType.COMMON] as Color
		common_chance_text = Util.convert_to_bbc_highlight_text(common_chance_text, chance_color)
		common_card_chance_label.text = Util.get_localized_string("BOOSTER_PACK_COMMON_CARD_CHANCE_TEXT")% common_chance_text
	else:
		common_card_chance_label.hide()

	if rare_chance > 0:
		rare_card_chance_label.show()
		var rare_chance_text := str(rare_chance) + "%"
		var chance_color := TYPE_COLORS[ContractData.BoosterPackType.RARE] as Color
		rare_chance_text = Util.convert_to_bbc_highlight_text(rare_chance_text, chance_color)
		rare_card_chance_label.text = Util.get_localized_string("BOOSTER_PACK_RARE_CARD_CHANCE_TEXT")% rare_chance_text
	else:
		rare_card_chance_label.hide()

	if legendary_chance > 0:
		legendary_card_chance_label.show()
		var legendary_chance_text := str(legendary_chance) + "%"
		var chance_color := TYPE_COLORS[ContractData.BoosterPackType.LEGENDARY] as Color
		legendary_chance_text = Util.convert_to_bbc_highlight_text(legendary_chance_text, chance_color)
		legendary_card_chance_label.text = Util.get_localized_string("BOOSTER_PACK_LEGENDARY_CARD_CHANCE_TEXT")% legendary_chance_text
	else:
		legendary_card_chance_label.hide()
