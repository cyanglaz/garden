class_name GUITopPlayerHP
extends HBoxContainer

@onready var _label_value: Label = %LabelValue
@onready var _label_max_value: Label = %LabelMaxValue

func bind_player(player:Player) -> void:
	player.hp.value_update.connect(_on_hp_changed.bind(player.hp))	
	player.hp.max_value_update.connect(_on_max_hp_changed.bind(player.hp))
	update_hp(player.hp)

func update_hp(hp:ResourcePoint) -> void:
	_label_value.text = str(hp.value)
	_label_max_value.text = str(hp.max_value)

func _on_hp_changed(hp:ResourcePoint) -> void:
	update_hp(hp)

func _on_max_hp_changed(hp:ResourcePoint) -> void:
	update_hp(hp)
