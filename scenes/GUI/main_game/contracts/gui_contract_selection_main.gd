class_name GUICombatSelectionMain
extends Control

signal combat_selected(combat_data:CombatData)

const COMBAT_SCENE := preload("res://scenes/GUI/main_game/combats/gui_combat_selection.tscn")

@onready var _combat_container: HBoxContainer = %CombatContainer
@onready var _title_label: Label = %TitleLabel

func _ready() -> void:
	_title_label.text = Util.get_localized_string("COMBAT_SELECTION_TITLE_TEXT")

func animate_show_with_combats(combats:Array) -> void:
	_update_with_combats(combats)
	if combats[0].combat_type == CombatData.CombatType.BOSS:
		_title_label.text = Util.get_localized_string("COMBAT_SELECTION_BOSS_TITLE_TEXT")
	else:
		_title_label.text = Util.get_localized_string("COMBAT_SELECTION_TITLE_TEXT")
	show()

func _update_with_combats(combats:Array) -> void:
	Util.remove_all_children(_combat_container)
	for combat:CombatData in combats:
		var gui_combat:GUICombatSelection = COMBAT_SCENE.instantiate()
		_combat_container.add_child(gui_combat)
		gui_combat.update_with_combat_data(combat)
		gui_combat.combat_selected.connect(_on_combat_selected)

func _on_combat_selected(combat:CombatData) -> void:
	hide()
	Util.remove_all_children(_combat_container)
	combat_selected.emit(combat)
