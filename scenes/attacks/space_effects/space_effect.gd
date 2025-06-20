class_name SpaceEffect
extends RefCounted

const STACK_DESCRIPTION := "\n\nStack: [outline_size=1][color=%s]%s[/color][/outline_size]"

signal request_handle_bingo_event(bingo_space_data:BingoSpaceData, bingo_result:BingoResult)

enum EventTriggerType {
	BINGO,
}

signal _bingo_event_finished()

var data:SpaceEffectData
var stack:int
var gui_space_effect:GUISpaceEffect: set=set_gui_space_effect, get=get_gui_space_effect
var _weak_gui_space_effect:WeakRef = weakref(null)

func _init(d:SpaceEffectData, s:int) -> void:
	stack = s
	data = d

func get_duplicate() -> SpaceEffect:
	var dup:SpaceEffect = SpaceEffect.new(data.get_duplicate(), stack)
	return dup

func block_bingo() -> bool:
	return false

func handle_bingo_event(bingo_space_data:BingoSpaceData, bingo_result:BingoResult) -> void:
	if _has_bingo_event(bingo_space_data):
		request_handle_bingo_event.emit(bingo_space_data, bingo_result)
		gui_space_effect.trigger_animation_finished.connect(_on_trigger_animation_finished.bind(bingo_space_data, EventTriggerType.BINGO))
		gui_space_effect.animate_trigger(0.2)
		await _bingo_event_finished

func get_formatted_description() -> String:
	var formatted_description := data.description.format(data.data)
	if !data.show_stack:
		return formatted_description
	var stack_description := STACK_DESCRIPTION % [Util.get_color_hex(Constants.TOOLTIP_HIGHLIGHT_COLOR_GREEN), stack]
	return formatted_description + stack_description

#region condition checks
func _has_bingo_event(_bingo_space_data:BingoSpaceData) -> bool:
	return false

#endregion

#region getter/setter
func set_gui_space_effect(v:GUISpaceEffect) -> void:
	_weak_gui_space_effect = weakref(v)

func get_gui_space_effect() -> GUISpaceEffect:
	return _weak_gui_space_effect.get_ref()
#endregion

#region for overrides
func _on_trigger_animation_finished(bingo_space_data:BingoSpaceData, event_trigger_type:EventTriggerType) -> void:
	gui_space_effect.trigger_animation_finished.disconnect(_on_trigger_animation_finished.bind(bingo_space_data, event_trigger_type))
