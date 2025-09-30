class_name GUIContractView
extends Control

@onready var gui_contract: GUIContract = %GUIContract

@onready var _back_button: GUIRichTextButton = %BackButton

func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)

func show_with_contract_data(contract_data:ContractData) -> void:
	gui_contract.update_with_contract_data(contract_data)
	show()

func _on_back_button_pressed() -> void:
	hide()
