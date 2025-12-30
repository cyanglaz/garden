class_name GUIChestRewardCard
extends GUIChestRewardItem

@onready var gui_tool_card_button: GUIToolCardButton = %GUIToolCardButton

func _ready() -> void:
	super._ready()
	gui_tool_card_button.mouse_disabled = false
	gui_tool_card_button.mute_interaction_sounds = true

func update_with_data(data:ToolData) -> void:
	gui_tool_card_button.update_with_tool_data(data)

func play_move_sound() -> void:
	gui_tool_card_button.play_discard_sound()
