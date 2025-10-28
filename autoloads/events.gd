extends Node

@warning_ignore("unused_signal")
signal test_signal()

# Apply shake screen effects.
# See https://www.youtube.com/watch?v=tu-Qe66AvtY for meaning of the parameters
# decay is how fast the shake stops, the larger the decay, the faster the shake stops
@warning_ignore("unused_signal")
signal request_camera_shake_effects(trauma:float, amplitude:Vector2, rotaton:float, decay:float, priority:int)
@warning_ignore("unused_signal")
signal request_camera_default_shake_effects(trauma:float)
@warning_ignore("unused_signal")
signal request_slow_motion(scale:float, time:float)
@warning_ignore("unused_signal")
signal request_zoom_in(zoom_global_position:Vector2)
@warning_ignore("unused_signal")
signal request_zoom_out()
@warning_ignore("unused_signal")
signal camera_zoom_in_finished()
@warning_ignore("unused_signal")
signal camera_zoom_out_finished()

# Main game global events
@warning_ignore("unused_signal")
signal request_rating_update(val:int)
@warning_ignore("unused_signal")
signal request_view_cards(cards:Array, title:String)
@warning_ignore("unused_signal")
signal request_show_info_view(data:Resource)
@warning_ignore("unused_signal")
signal request_show_warning(warning_type:WarningManager.WarningType)
@warning_ignore("unused_signal")
signal request_hide_warning(warning_type:WarningManager.WarningType)
@warning_ignore("unused_signal")
signal request_show_custom_error(message:String, id:String)
@warning_ignore("unused_signal")
signal request_hide_custom_error(id:String)
@warning_ignore("unused_signal")
signal update_hovered_data(data:Resource)
@warning_ignore("unused_signal")
signal request_update_gold(val:int, animated:bool)

@warning_ignore("unused_signal")
signal request_display_tooltip(tooltip_type:GUITooltipContainer.TooltipType, data:Variant, id:String, on_control_node:Control, anchor_mouse:bool, tooltip_position: GUITooltip.TooltipPosition, world_space:bool)
@warning_ignore("unused_signal")
signal request_hide_tooltip(id:String)
@warning_ignore("unused_signal")
signal request_display_popup_things(thing:PopupThing, height:float, spread:float, show_time:float, destroy_time:float, global_position:Vector2)
