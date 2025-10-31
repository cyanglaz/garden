class_name GUIBoss
extends HBoxContainer

@onready var gui_boss_icon: GUIBossIcon = %GUIBossIcon

var _combat_main:CombatMain: set = _set_combat_main, get = _get_combat_main

var _tooltip_id:String = ""
var _weak_combat_main:WeakRef = weakref(null)
var _weak_boss_data:WeakRef = weakref(null)

func _ready() -> void:
	gui_boss_icon.mouse_entered.connect(_on_mouse_entered)
	gui_boss_icon.mouse_exited.connect(_on_mouse_exited)

func update_with_boss_data(boss_data:BossData, combat_main:CombatMain) -> void:
	_weak_boss_data = weakref(boss_data)
	_combat_main = combat_main

func _on_mouse_entered() -> void:
	gui_boss_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.BOSS, _weak_boss_data.get_ref(), _tooltip_id, self, false, GUITooltip.TooltipPosition.BOTTOM_LEFT, false)
	Events.update_hovered_data.emit(_weak_boss_data.get_ref())

func _on_mouse_exited() -> void:
	gui_boss_icon.has_outline = false
	Events.update_hovered_data.emit(null)
	Events.request_hide_tooltip.emit(_tooltip_id)

func _set_combat_main(value:CombatMain) -> void:
	_weak_combat_main = weakref(value)

func _get_combat_main() -> CombatMain:
	return _weak_combat_main.get_ref()
