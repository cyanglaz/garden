class_name GUIPopupContainer
extends Control

const POPUP_CENTER_SCALE:float = 0.5

signal dismissed()

enum ShowAnimationType {
	POP_FROM_BOTTOM_TO_CENTER,
	POP_FROM_TOP_TO_CENTER,
	POP_IN_CENTER,
	POP_FROM_BOTTOM_TO_ORIGINAL_POSITION,
}

@export var show_animation_type:ShowAnimationType

func animate_show() -> void:
	match show_animation_type:
		ShowAnimationType.POP_FROM_BOTTOM_TO_CENTER:
			await _animate_pop_from_bottom()
		ShowAnimationType.POP_FROM_TOP_TO_CENTER:
			await _animate_pop_from_top()
		ShowAnimationType.POP_IN_CENTER:
			await _animate_pop_in_center()
		ShowAnimationType.POP_FROM_BOTTOM_TO_ORIGINAL_POSITION:
			await _animate_pop_from_bottom_to_original_position()

func animate_hide() -> void:
	match show_animation_type:
		ShowAnimationType.POP_FROM_BOTTOM_TO_CENTER:
			await _animate_hide_to_bottom()
		ShowAnimationType.POP_FROM_TOP_TO_CENTER:
			await _animate_hide_to_top()
		ShowAnimationType.POP_IN_CENTER:
			await _animate_hide_in_center()
		ShowAnimationType.POP_FROM_BOTTOM_TO_ORIGINAL_POSITION:
			await _animate_hide_to_bottom()
	dismissed.emit()

#region Show

func _animate_pop_from_bottom() -> void:
	# Position title banner centered horizontally and halfway outside panel container
	position.y = get_viewport_rect().size.y  # Start from bottom of screen
	show()
	var tween = create_tween()
	tween.tween_property(self, "position:y", 
		get_viewport_rect().size.y / 2 - size.y/2, 0.2  # Move to center of screen
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _animate_pop_from_top() -> void:
	# Position title banner centered horizontally and halfway outside panel container
	position.y = - size.y # Start from top of screen
	show()
	var tween = create_tween()
	tween.tween_property(self, "position:y", 
		get_viewport_rect().size.y / 2 - size.y/2, 0.2  # Move to center of screen
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _animate_pop_in_center() -> void:

	pivot_offset_ratio = Vector2.ONE * 0.5
	# Center the panel
	position = Vector2(
		get_viewport_rect().size.x / 2 - size.x / 2,
		get_viewport_rect().size.y / 2 - size.y / 2
	)
	scale = Vector2(POPUP_CENTER_SCALE, POPUP_CENTER_SCALE)
	show()
	
	var tween = create_tween()
	tween.tween_property(self, "scale", 
		Vector2.ONE, 0.2
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _animate_pop_from_bottom_to_original_position() -> void:
	var original_y:float = position.y
	position.y = get_viewport_rect().size.y  # Start from bottom of screen
	show()
	var tween = create_tween()
	tween.tween_property(self, "position:y",
		original_y, 0.2  # Move to original position
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
#endregion

#region Hide
func _animate_hide_to_bottom() -> void:
	var original_y:float = position.y
	var tween = create_tween()
	tween.tween_property(self, "position:y",
		get_viewport_rect().size.y, 0.2  # Move to bottom of screen
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
	position.y = original_y

func _animate_hide_to_top() -> void:
	var original_y:float = position.y
	var tween = create_tween()
	tween.tween_property(self, "position:y",
		- self.size.y, 0.2  # Move to bottom of screen
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
	position.y = original_y

func _animate_hide_in_center() -> void:
	var original_y:float = position.y
	var tween = create_tween()
	tween.tween_property(self, "scale", 
		Vector2(POPUP_CENTER_SCALE, POPUP_CENTER_SCALE), 0.2
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
	position.y = original_y
#endregion
