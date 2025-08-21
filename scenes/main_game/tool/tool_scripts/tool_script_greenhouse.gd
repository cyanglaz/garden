class_name ToolScriptGreenhouse
extends ToolScript

const GREENHOUSE_FIELD_STATUS_DATA := preload("res://data/field_status/field_status_greenhouse.tres")

func apply_tool(_main_game:MainGame, fields:Array, field_index:int, _tool_data:ToolData) -> void:
	var field:Field = fields[field_index]
	await field.apply_field_status(GREENHOUSE_FIELD_STATUS_DATA.id, 1)
