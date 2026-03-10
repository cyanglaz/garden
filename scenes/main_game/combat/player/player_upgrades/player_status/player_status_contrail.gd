class_name PlayerStatusContrail
extends PlayerStatus

func _has_player_move_hook(_main_game:CombatMain) -> bool:
	return true

func _handle_player_move_hook(main_game:CombatMain) -> void:
	var plant:Plant = main_game.get_current_player_plant()
	var action:ActionData = ActionData.new()
	action.type = ActionData.ActionType.WATER
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = stack * (status_data.data["value"] as int)
	await plant.apply_actions([action])
