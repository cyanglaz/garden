extends GutTest


class FakeToolCardButton extends GUIToolCardButton:
	var fake_tool_data: ToolData
	var fake_card_state := GUICardFace.CardState.NORMAL
	var fake_resource_sufficient := true

	func _set_tool_data(value: ToolData) -> void:
		fake_tool_data = value

	func _get_tool_data() -> ToolData:
		return fake_tool_data

	func _set_card_state(value: GUICardFace.CardState) -> void:
		fake_card_state = value

	func _get_card_state() -> GUICardFace.CardState:
		return fake_card_state

	func _set_resource_sufficient(value: bool) -> void:
		fake_resource_sufficient = value

	func _get_resource_sufficient() -> bool:
		return fake_resource_sufficient

	func play_error_shake_animation() -> void:
		pass


func _make_tool_data(id_value: String) -> ToolData:
	var tool_data := ToolData.new()
	tool_data.id = id_value
	tool_data.energy_cost = 1
	autofree(tool_data)
	return tool_data


func _make_container_with_card(tool_data: ToolData, is_mid_turn: bool) -> Dictionary:
	var container := GUIToolCardContainer.new()
	autofree(container)
	var card_holder := Control.new()
	autofree(card_holder)
	card_holder.size = Vector2(220, 70)
	container._container = card_holder
	container._card_size = GUIToolCardButton.SIZE.x
	container.is_mid_turn = is_mid_turn

	var card := FakeToolCardButton.new()
	autofree(card)
	card.tool_data = tool_data
	card.resource_sufficient = true
	card.card_state = GUICardFace.CardState.NORMAL
	card_holder.add_child(card)
	return {"container": container, "card": card}


func test_on_tool_card_pressed_ignored_when_not_mid_turn() -> void:
	var setup := _make_container_with_card(_make_tool_data("tool_idle"), false)
	var container: GUIToolCardContainer = setup["container"]

	var selected_tools: Array[ToolData] = []
	container.main_card_selected.connect(func(tool_data: ToolData) -> void: selected_tools.append(tool_data))
	container._on_tool_card_pressed(0)

	assert_eq(selected_tools.size(), 0)


func test_on_tool_card_pressed_emits_main_card_selected_when_mid_turn() -> void:
	var tool_data := _make_tool_data("tool_mid_turn")
	var setup := _make_container_with_card(tool_data, true)
	var container: GUIToolCardContainer = setup["container"]
	var card: FakeToolCardButton = setup["card"]

	var selected_tools: Array[ToolData] = []
	container.main_card_selected.connect(func(selected: ToolData) -> void: selected_tools.append(selected))
	container._on_tool_card_pressed(0)

	assert_eq(selected_tools.size(), 1)
	assert_true(selected_tools[0] == tool_data)
	assert_eq(card.card_state, GUICardFace.CardState.NORMAL)
