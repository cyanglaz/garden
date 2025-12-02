class_name GUICombatSelection
extends VBoxContainer

signal combat_selected(combat:CombatData)

@onready var gui_combat: GUICombat = %GUICombat
@onready var gui_rich_text_button: GUIRichTextButton = %GUIRichTextButton

func update_with_combat_data(combat:CombatData) -> void:
	gui_combat.update_with_combat_data(combat)
	gui_rich_text_button.pressed.connect(_on_button_pressed.bind(combat))
	gui_rich_text_button.mouse_entered.connect(func() -> void: gui_combat.has_outline = true)
	gui_rich_text_button.mouse_exited.connect(func() -> void: gui_combat.has_outline = false)

func _on_button_pressed(combat:CombatData) -> void:
	combat_selected.emit(combat)
