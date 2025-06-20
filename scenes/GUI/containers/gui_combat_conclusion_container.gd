class_name GUICombatConclusionContainer
extends GUIPopupContainer

@onready var gui_combat_conclusion: GUICombatConclusion = %GUICombatConclusion
@onready var ok_button: GUIRichTextButton = %OKButton

func _ready() -> void:
	ok_button.action_evoked.connect(_on_ok_button_action_evoked)

func setup(combat_conclusion:CombatConclusion) -> void:
	gui_combat_conclusion.setup_with_combat_conclusion(combat_conclusion)

func _on_ok_button_action_evoked() -> void:
	get_tree().change_scene_to_file(MainMenu.SCENE_PATH)
