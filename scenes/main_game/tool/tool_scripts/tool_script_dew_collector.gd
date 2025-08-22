class_name ToolScriptDewCollector
extends ToolScript

const DEW_COLLECTOR_FIELD_STATUS_DATA := preload("res://data/field_status/field_status_dew_collector.tres")

func apply_tool(_main_game:MainGame, fields:Array, field_index:int, _tool_data:ToolData) -> void:
	var field:Field = fields[field_index]
	await field.apply_field_status(DEW_COLLECTOR_FIELD_STATUS_DATA.id, 1)
