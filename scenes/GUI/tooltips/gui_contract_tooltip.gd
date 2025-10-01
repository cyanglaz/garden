class_name GUIContractTooltip
extends GUITooltip

@onready var gui_contract: GUIContract = %GUIContract

func update_with_contract_data(contract_data:ContractData) -> void:
	gui_contract.update_with_contract_data(contract_data)
