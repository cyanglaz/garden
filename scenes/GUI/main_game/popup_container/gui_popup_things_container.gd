class_name GUIPopupThingsContainer
extends Control

var _all_popup_things:Array[PopupThing] = []

func _ready() -> void:
	Events.request_display_popup_things.connect(_on_request_display_popup_things)

func _on_request_display_popup_things(thing:PopupThing, height:float, spread:float, show_time:float, destroy_time:float, global_location:Vector2) -> void:
	_all_popup_things.append(thing)
	add_child(thing)
	thing.global_position = global_location
	_bump_up_overlapping_popup_things.call_deferred(thing)
	await thing.animate_show(height, spread, show_time)
	await thing.animate_destroy(destroy_time)
	_all_popup_things.erase(thing)

func _find_overlapping_popup_things(new_thing:PopupThing) -> Array[PopupThing]:
	var overlapping_popup_things:Array[PopupThing] = []
	for popup_thing in _all_popup_things:
		assert(is_instance_valid(popup_thing))
		if popup_thing == new_thing:
			# Only bump up things that show before this.
			break
		var end_rect := Rect2(popup_thing.end_position, popup_thing.size)
		var other_end_rect := Rect2(new_thing.end_position, new_thing.size)
		if end_rect.intersects(other_end_rect):
			overlapping_popup_things.append(popup_thing)
	return overlapping_popup_things

func _bump_up_overlapping_popup_things(new_thing:PopupThing) -> void:
	var overlapping_popup_things := _find_overlapping_popup_things(new_thing)
	for overlapped_popup_thing:PopupThing in overlapping_popup_things:
		var bump_up_height := overlapped_popup_thing.end_position.y - new_thing.end_position.y + overlapped_popup_thing.size.y + PopupThing.BUMP_UP_DISTANCE
		_bump_up_overlapping_popup_things.call_deferred(overlapped_popup_thing)
		overlapped_popup_thing.bump_up(bump_up_height)
