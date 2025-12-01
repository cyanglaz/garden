class_name GUIContractTooltip
extends GUITooltip

@onready var gui_contract: GUIContract = %GUIContract

func _update_with_tooltip_request() -> void:
	var contract_data:ContractData = _tooltip_request.data as ContractData
	gui_contract.update_with_contract_data(contract_data)
