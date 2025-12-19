class_name TavernField
extends Field

const HP_INCREASE := 4

@onready var tavern: Tavern = %Tavern
@onready var tavern_sign: BuildingSign = %TavernSign

var _tooltip_id:String = "tavern"
var interacted := false
var highlighted := false: set = _set_highlighted

func _on_gui_plant_button_mouse_entered() -> void:
	super._on_gui_plant_button_mouse_entered()
	highlighted = true
	var building_name := Util.get_localized_string("TAVERN_NAME")
	var building_description := Util.get_localized_string("TAVERN_DESCRIPTION") % HP_INCREASE
	building_description = DescriptionParser.format_references(building_description, {}, {}, func(_reference_id:String) -> bool: return false)
	Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.TOWN_BUILDING, null, _tooltip_id, _gui_field_button, GUITooltip.TooltipPosition.BOTTOM, {"name": building_name, "description": building_description}))

func _on_gui_plant_button_mouse_exited() -> void:
	super._on_gui_plant_button_mouse_exited()
	highlighted = false || interacted
	tavern_sign.highlighted = false
	tavern.highlighted = false
	Events.request_hide_tooltip.emit(_tooltip_id)

func _set_highlighted(val:bool) -> void:
	highlighted = val
	if highlighted:
		tavern_sign.highlighted = true
		tavern.highlighted = true
	else:
		tavern_sign.highlighted = false
		tavern.highlighted = false
