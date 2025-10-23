class_name GUIBossIcon
extends GUIIcon

var _weak_boss_tooltip:WeakRef = weakref(null)
var _weak_boss_data:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_with_boss_data(boss_data:BossData) -> void:
	_weak_boss_data = weakref(boss_data)

func _on_mouse_entered() -> void:
	has_outline = true
	_weak_boss_tooltip = weakref(Util.display_boss_tooltip(_weak_boss_data.get_ref(), self, false, GUITooltip.TooltipPosition.BOTTOM_LEFT))
	Events.update_hovered_data.emit(_weak_boss_data.get_ref())

func _on_mouse_exited() -> void:
	has_outline = false
	Events.update_hovered_data.emit(null)
	if _weak_boss_tooltip.get_ref():
		_weak_boss_tooltip.get_ref().queue_free()
		_weak_boss_tooltip = weakref(null)
