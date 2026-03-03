class_name GUIEventMain
extends CanvasLayer

const SCRIPT_PREFIX := "res://scenes/main_game/event/event_option_scripts/event_option_script_"
const OPTION_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_event_option_button.tscn")

signal event_finished()

@onready var description: RichTextLabel = %Description
@onready var button_containers: VBoxContainer = %ButtonContainers

func update_with_event(event:EventData, main_game:MainGame) -> void:
	description.text = DescriptionParser.format_references(event.description, event.data, {}, func(_reference_id:String) -> bool: return false)
	for option_id in event.option_ids:
		var option_data: EventOptionData = MainDatabase.event_option_database.get_data_by_id(str(event.id, "_", option_id))
		var option_button: GUIEventOptionButton = OPTION_BUTTON_SCENE.instantiate()
		button_containers.add_child(option_button)
		option_button.update_with_option(option_data)
		option_button.pressed.connect(_on_option_button_pressed.bind(event, option_data))
		var script: EventOptionScript = _get_script(event.id, option_data)
		if script.should_enable(option_data, main_game):
			option_button.button_state = GUIBasicButton.ButtonState.NORMAL
		else:
			option_button.button_state = GUIBasicButton.ButtonState.DISABLED

func _on_option_button_pressed(event: EventData, option_data: EventOptionData) -> void:
	var script: EventOptionScript = _get_script(event.id, option_data)
	await script.run(option_data)
	event_finished.emit()

func _get_script(event_id:String, option_data: EventOptionData) -> EventOptionScript:
	var script_id := option_data.script_id
	if script_id.is_empty():
		script_id = str(event_id, "_", option_data.id)
	return load(str(SCRIPT_PREFIX, script_id, ".gd")).new()
