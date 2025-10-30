class_name GUIContractTooltip
extends GUITooltip

@onready var gui_contract: GUIContract = %GUIContract

func _update_with_data() -> void:
	var contract_data:ContractData = _data as ContractData
	gui_contract.update_with_contract_data(contract_data)