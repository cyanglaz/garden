class_name GUILibraryLeftBar
extends VBoxContainer

signal button_pressed(category:String)

@onready var card_button: GUILibraryCategoryButton = %CardButton
@onready var plants_button: GUILibraryCategoryButton = %PlantsButton
@onready var misc_button: GUILibraryCategoryButton = %MiscButton
@onready var bosses_button: GUILibraryCategoryButton = %BossesButton

func _ready() -> void:
	card_button.pressed.connect(func(): button_pressed.emit("card"))
	plants_button.pressed.connect(func(): button_pressed.emit("plant"))
	misc_button.pressed.connect(func(): button_pressed.emit("misc"))
	bosses_button.pressed.connect(func(): button_pressed.emit("boss"))
