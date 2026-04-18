class_name GUIEnchantIcon
extends PanelContainer

@export var mouse_interaction_enabled: bool = true

@onready var gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var label: Label = %Label

var _tooltip_id: String = ""
var _enchant_data:EnchantData

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	label.add_theme_color_override("font_color", Constants.ENCHANT_TEXT_COLOR)
	label.add_theme_color_override("font_outline_color", Constants.ENCHANT_TEXT_OUTLINE_COLOR)

func update_with_enchant_data(enchant_data: EnchantData, combat_main: CombatMain) -> void:
	_enchant_data = enchant_data
	gui_action_type_icon.update_with_action_type(enchant_data.action_data.type)
	label.text = str(enchant_data.action_data.get_calculated_value(combat_main))

func _on_mouse_entered() -> void:
	if !mouse_interaction_enabled:
		return
	gui_action_type_icon.is_highlighted = true
	label.add_theme_color_override("font_outline_color", Constants.COLOR_WHITE)
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(
		TooltipRequest.TooltipType.ENCHANT,
		_enchant_data,
		_tooltip_id,
		self,
		GUITooltip.TooltipPosition.RIGHT
	))

func _on_mouse_exited() -> void:
	if !mouse_interaction_enabled:
		return
	gui_action_type_icon.is_highlighted = false
	label.add_theme_color_override("font_outline_color", Constants.ENCHANT_TEXT_OUTLINE_COLOR)
	Events.request_hide_tooltip.emit(_tooltip_id)
