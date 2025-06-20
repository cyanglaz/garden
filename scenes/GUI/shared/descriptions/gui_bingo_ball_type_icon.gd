class_name GUIBingoBallTypeIcon
extends TextureRect

const ATTACK_ICON := preload("res://resources/sprites/icons/ball_types/icon_ball_type_attack.png")
const SKILL_ICON := preload("res://resources/sprites/icons/ball_types/icon_ball_type_skill.png")
const STATUS_ICON := preload("res://resources/sprites/icons/ball_types/icon_ball_type_status.png")

@export var tooltip_position :GUITooltip.TooltipPosition

var _weak_tooltip:WeakRef = weakref(null)
var _type:BingoBallData.Type

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_default_cursor_shape = Control.CursorShape.CURSOR_HELP

func bind_bingo_ball_data(bingo_ball_data:BingoBallData) -> void:
	_type = bingo_ball_data.type
	match _type:
		BingoBallData.Type.ATTACK:
			texture = ATTACK_ICON
		BingoBallData.Type.SKILL:
			texture = SKILL_ICON
		BingoBallData.Type.STATUS:
			texture = STATUS_ICON

func _on_mouse_entered() -> void:
	var text := ""
	match _type:
		BingoBallData.Type.ATTACK:
			text = tr("CARD_TYPE_TOOLTIP_ATTACK")
		BingoBallData.Type.SKILL:
			text = tr("CARD_TYPE_TOOLTIP_SKILL")
		BingoBallData.Type.STATUS:
			text = tr("CARD_TYPE_TOOLTIP_STATUS")

	_weak_tooltip = weakref(Util.display_rich_text_tooltip(text, self, true, tooltip_position))
