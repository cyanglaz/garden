class_name GUIContractSelectionMain
extends Control

signal contract_selected(contract_data:ContractData)

const CONTRACT_SCENE := preload("res://scenes/GUI/main_game/contracts/gui_contract_selection.tscn")

@onready var _contract_container: HBoxContainer = %ContractContainer
@onready var _title_label: Label = %TitleLabel

func _ready() -> void:
	_title_label.text = Util.get_localized_string("CONTRACT_SELECTION_TITLE_TEXT")

func animate_show_with_contracts(contracts:Array) -> void:
	_update_with_contracts(contracts)
	show()

func _update_with_contracts(contracts:Array) -> void:
	Util.remove_all_children(_contract_container)
	for contract:ContractData in contracts:
		var gui_contract:GUIContractSelection = CONTRACT_SCENE.instantiate()
		_contract_container.add_child(gui_contract)
		gui_contract.update_with_contract_data(contract)
		gui_contract.contract_selected.connect(_on_contract_selected)

func _on_contract_selected(contract:ContractData) -> void:
	hide()
	Util.remove_all_children(_contract_container)
	contract_selected.emit(contract)
