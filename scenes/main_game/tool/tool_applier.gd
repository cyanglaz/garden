class_name ToolApplier
extends RefCounted

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)

var _actions_applier:ActionsApplier = ActionsApplier.new()

func apply_tool(combat_main:CombatMain, tool_data:ToolData, secondary_card_datas:Array, tool_card:GUIToolCardButton) -> void:
	tool_application_started.emit(tool_data)
	match tool_data.type:
		ToolData.Type.SKILL:
			if tool_data.tool_script:
				await tool_data.tool_script.apply_tool(combat_main, tool_data, secondary_card_datas)
			else:
				await _actions_applier.apply_actions(tool_data.actions, combat_main, secondary_card_datas, tool_card)
		ToolData.Type.POWER:
			combat_main.player.player_status_container.update_status(tool_data.id, 1, ActionData.OperatorType.INCREASE)
			await Util.create_scaled_timer(Constants.GLOBAL_UPGRADE_PAUSE_TIME).timeout
	tool_application_completed.emit(tool_data)
