class_name GUITavernMain
extends CanvasLayer

const RATING_GAIN_FREE := 5
const RATING_GAIN_PAID := 15
const RATING_GAIN_PAID_COST := 12
const GOLD_GAIN := 18
const EVENT_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_event_selection_button.tscn")

@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var buttons_container: VBoxContainer = %ButtonsContainer
@onready var free_rating_button: GUIEventSelectionButton = %FreeRatingButton
@onready var paid_rating_button: GUIEventSelectionButton = %PaidRatingButton
@onready var gain_gold_button: GUIEventSelectionButton = %GainGoldButton


func _ready() -> void:
	description_label.text = Util.get_localized_string("TAVERN_DESCRIPTION")
	free_rating_button.label.text = DescriptionParser.format_references(Util.get_localized_string("TAVERN_FREE_RATING") % RATING_GAIN_FREE, {}, {}, func(_reference_id:String) -> bool: return false)
	paid_rating_button.label.text = DescriptionParser.format_references(Util.get_localized_string("TAVERN_PAID_RATING") % [RATING_GAIN_PAID_COST, RATING_GAIN_PAID], {}, {}, func(_reference_id:String) -> bool: return false)
	gain_gold_button.label.text = DescriptionParser.format_references(Util.get_localized_string("TAVERN_GAIN_GOLD") % GOLD_GAIN, {}, {}, func(_reference_id:String) -> bool: return false)
	
