class_name GUIFieldStatusIcon
extends PanelContainer

@onready var _icon: TextureRect = %Icon
@onready var _stack: Label = %Stack

var status_id:String = ""

func setup_with_field_status_data(field_status_data:FieldStatusData) -> void:
	_icon.texture = load(Util.get_image_path_for_resource_id(field_status_data.id))
	_stack.text = str(field_status_data.stack)
	status_id = field_status_data.id

func play_trigger_animation() -> void:
	pass
