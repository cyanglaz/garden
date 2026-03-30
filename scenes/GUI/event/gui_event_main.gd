class_name GUIEventMain
extends CanvasLayer

const OPTION_SCRIPT_PREFIX := "res://scenes/main_game/event/event_option_scripts/event_option_script_"
const EVENT_SCRIPT_PREFIX := "res://scenes/main_game/event/event_scripts/event_script_"
const OPTION_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_event_option_button.tscn")

signal event_finished(meta:Variant)

@onready var description: RichTextLabel = %Description
@onready var button_containers: VBoxContainer = %ButtonContainers
@onready var sub_scene_container: Control = %SubSceneContainer

func _ready() -> void:
	description.meta_underlined = false

func update_with_event(event:EventData, main_game:MainGame) -> void:
	var event_script: EventScript = _get_event_script(event.id)
	if event_script:
		event_script.prepare(event, main_game)
	description.text = event.get_display_description()
	description.meta_hover_started.connect(_on_meta_hover_started.bind(event))
	description.meta_hover_ended.connect(_on_meta_hover_ended.bind(event))
	description.meta_clicked.connect(_on_meta_clicked.bind(event))
	for option_id in event.option_ids:
		var option_data: EventOptionData = MainDatabase.event_option_database.get_data_by_id(str(event.id, "_", option_id))
		var script: EventOptionScript = _get_option_script(event.id, option_data)
		script.prepare(event, main_game, option_data)
		var option_button: GUIEventOptionButton = OPTION_BUTTON_SCENE.instantiate()
		button_containers.add_child(option_button)
		option_button.update_with_option(option_data)
		option_button.pressed.connect(_on_option_button_pressed.bind(event, option_data, main_game))
		option_button.mouse_entered.connect(_on_option_button_mouse_entered.bind(option_data, option_button))
		option_button.mouse_exited.connect(_on_option_button_mouse_exited.bind(option_data))
		if script.should_enable(option_data, main_game):
			option_button.button_state = GUIBasicButton.ButtonState.NORMAL
		else:
			option_button.button_state = GUIBasicButton.ButtonState.DISABLED

func _get_option_script(event_id:String, option_data: EventOptionData) -> EventOptionScript:
	var script_id := option_data.script_id
	if script_id.is_empty():
		script_id = str(event_id, "_", option_data.id)
	return load(str(OPTION_SCRIPT_PREFIX, script_id, ".gd")).new()

func _get_event_script(event_id:String) -> EventScript:
	var path := str(EVENT_SCRIPT_PREFIX, event_id, ".gd")
	if FileAccess.file_exists(path):
		return load(path).new()
	return null

func _on_meta_hover_started(meta: String, event_data: EventData) -> void:
	if meta == "card":
		var card_id:String = event_data.data["card"]
		var card_data:ToolData = MainDatabase.tool_database.get_data_by_id(card_id)
		Events.update_hovered_data.emit(card_data)

func _on_meta_hover_ended(_meta: String, _event_data: EventData) -> void:
	Events.update_hovered_data.emit(null)

func _on_meta_clicked(meta: String, event_data: EventData) -> void:
	if meta == "card":
		var card_id:String = event_data.data["card"]
		var card_data:ToolData = MainDatabase.tool_database.get_data_by_id(card_id)
		Events.request_show_info_view.emit(card_data)

func _on_option_button_pressed(event: EventData, option_data: EventOptionData, main_game: MainGame) -> void:
	var script: EventOptionScript = _get_option_script(event.id, option_data)
	script.request_add_sub_scene.connect(_on_request_add_sub_scene)
	var meta:Variant = await script.run(option_data, main_game)
	event_finished.emit(meta)

func _on_option_button_mouse_entered(option_data: EventOptionData, option_button: GUIEventOptionButton) -> void:
	if option_data.data.has("card"):
		var card_id:String = option_data.data["card"]
		var card_data:ToolData = MainDatabase.tool_database.get_data_by_id(card_id)
		Events.update_hovered_data.emit(card_data)
	if option_data.data.has("trinket"):
		var trinket_id: String = option_data.data["trinket"]
		var trinket_data: TrinketData = MainDatabase.trinket_database.get_data_by_id(trinket_id)
		Events.request_display_tooltip.emit(TooltipRequest.new(
			TooltipRequest.TooltipType.THING_DATA,
			trinket_data,
			"event_option_trinket_tooltip",
			option_button,
			GUITooltip.TooltipPosition.TOP_RIGHT
		))

func _on_option_button_mouse_exited(_option_data: EventOptionData) -> void:
	Events.update_hovered_data.emit(null)
	Events.request_hide_tooltip.emit("event_option_trinket_tooltip")

func _on_request_add_sub_scene(sub_scene: Node) -> void:
	sub_scene_container.add_child(sub_scene)
