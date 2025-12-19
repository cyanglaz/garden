class_name ForgeField
extends Field

@onready var forge: Forge = %Forge
@onready var forge_sign: BuildingSign = %ForgeSign

var _tooltip_id:String = "forge"

func _on_gui_plant_button_mouse_entered() -> void:
	super._on_gui_plant_button_mouse_entered()
	forge_sign.highlighted = true
	forge.highlighted = true
	var building_name := Util.get_localized_string("FORGE_NAME")
	var building_description := Util.get_localized_string("FORGE_DESCRIPTION")
	building_description = DescriptionParser.format_references(building_description, {}, {}, func(_reference_id:String) -> bool: return false)
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.TOWN_BUILDING, null, _tooltip_id, _gui_field_button, GUITooltip.TooltipPosition.BOTTOM, {"name": building_name, "description": building_description}))

func _on_gui_plant_button_mouse_exited() -> void:
	super._on_gui_plant_button_mouse_exited()
	forge_sign.highlighted = false
	forge.highlighted = false
	Events.request_hide_tooltip.emit(_tooltip_id)
