class_name FieldStatusDrowned
extends FieldStatus

func has_prevent_resource_update_value_hook(resource_id:String, _plant:Plant, old_value:int, new_value:int) -> bool:
	return resource_id == "water" && new_value > old_value

func handle_prevent_resource_update_value_hook(_resource_id:String, _plant:Plant, _old_value:int, _new_value:int) -> bool:
	return true
