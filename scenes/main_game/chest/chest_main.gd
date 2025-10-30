class_name ChestMain
extends Node2D

@onready var gui_chest_main: GUIChestMain = %GUIChestMain
@onready var chest_container: ChestContainer = %ChestContainer

func update_with_number_of_chests(number_of_chests:int) -> void:
	chest_container.update_with_number_of_chests(number_of_chests)
