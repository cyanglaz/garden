class_name GUIBossTheBinder
extends GUIBoss

@onready var label: Label = %Label

func update_with_boss_data(boss_data:BossData, combat_main:CombatMain) -> void:
	super.update_with_boss_data(boss_data, combat_main)
	combat_main.turn_started.connect(_on_turn_started)
	combat_main.tool_manager.tool_application_completed.connect(_on_tool_application_completed)

func _on_turn_started() -> void:
	label.text = str(_combat_main.combat_modifier_manager.card_use_limit())
	_on_tool_application_completed(null)

func _on_tool_application_completed(_tool_data:ToolData) -> void:
	var card_used_this_turn = _combat_main.tool_manager.number_of_card_used_this_turn
	var card_use_left:int = _combat_main.combat_modifier_manager.card_use_limit() - card_used_this_turn
	label.text = str(card_use_left)
	match card_use_left:
		0:
			label.self_modulate = Constants.COLOR_RED
		1:
			label.self_modulate = Constants.COLOR_ORANGE2
		_:
			label.self_modulate = Constants.COLOR_YELLOW1
