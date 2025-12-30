class_name GUIToolSpecialIconButton
extends GUIBasicButton

signal special_interacted(special:ToolData.Special)
signal special_hovered(special:ToolData.Special, on:bool)

@onready var gui_icon: GUIIcon = %GUIIcon

var _special:ToolData.Special

func _ready() -> void:
	super._ready()
	pressed.connect(_on_pressed)

func update_with_special(special:ToolData.Special) -> void:
	_special = special
	var special_id := Util.get_id_for_tool_speical(special)
	gui_icon.texture = load(Util.get_image_path_for_resource_id(special_id))

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !gui_icon:
		return
	if button_state in [ButtonState.HOVERED]:
		gui_icon.is_highlighted = true
		gui_icon.pivot_offset = gui_icon.size/2
		gui_icon.scale = Vector2.ONE * 1.8
		gui_icon.z_index = 1
	else:
		gui_icon.is_highlighted = false
		gui_icon.pivot_offset = Vector2.ZERO
		gui_icon.scale = Vector2.ONE
		gui_icon.z_index = 0

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	special_hovered.emit(_special, true)
func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	special_hovered.emit(_special, false)

func _on_pressed() -> void:
	special_interacted.emit(_special)
