class_name GUIContractSelection
extends VBoxContainer

signal contract_selected(contract:ContractData)

@onready var gui_contract: GUIContract = %GUIContract
@onready var gui_rich_text_button: GUIRichTextButton = %GUIRichTextButton

func update_with_contract_data(contract:ContractData) -> void:
	gui_contract.update_with_contract_data(contract)
	gui_rich_text_button.pressed.connect(_on_button_pressed.bind(contract))
	gui_rich_text_button.mouse_entered.connect(func() -> void: gui_contract.has_outline = true)
	gui_rich_text_button.mouse_exited.connect(func() -> void: gui_contract.has_outline = false)

func _on_button_pressed(contract:ContractData) -> void:
	contract_selected.emit(contract)
