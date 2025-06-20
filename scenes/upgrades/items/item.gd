class_name Item
extends RefCounted

signal activation_toggled(on:bool)

var item_data:ItemData

@warning_ignore("unused_private_class_variable")
var _snapshot := Snapshot.new(self, ["item_data"])

func de_activate(phase:ItemData.ActivationPhase) -> void:
	if item_data.activation_phases.has(phase):
		activation_toggled.emit(false)
