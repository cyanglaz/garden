class_name GUIEnchantIcon
extends PanelContainer

@export var mouse_interaction_enabled: bool = true

@onready var gui_action_type_icon: GUIActionTypeIcon = %GUIActionTypeIcon
@onready var label: Label = %Label

var _tooltip_id: String = ""
var _weak_enchant_data: WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_enchant_data(enchant_data: EnchantData, combat_main: CombatMain) -> void:
	_weak_enchant_data = weakref(enchant_data)
	gui_action_type_icon.update_with_action_type(enchant_data.action_data.type)
	label.text = str(enchant_data.action_data.get_calculated_value(combat_main))

func _on_mouse_entered() -> void:
	if !mouse_interaction_enabled:
		return
	gui_action_type_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(TooltipRequest.new(
		TooltipRequest.TooltipType.ENCHANT,
		_weak_enchant_data.get_ref(),
		_tooltip_id,
		self,
		GUITooltip.TooltipPosition.RIGHT
	))

func _on_mouse_exited() -> void:
	if !mouse_interaction_enabled:
		return
	gui_action_type_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
