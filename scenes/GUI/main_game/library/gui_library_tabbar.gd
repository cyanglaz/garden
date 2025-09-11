@tool
class_name GUILibraryTabbar
extends GUITabControl

signal tab_evoked(data:ThingData)
signal all_tabs_cleared()

var datas:Array[ThingData]

func add_top_bar_button(data:ThingData) -> void:
	datas.append(data)
	_add_tab()
	var top_bar_button:GUILibraryTabbarButton = _buttons_container.get_child(datas.size() - 1)
	top_bar_button.update_with_data(data)
	select_button(datas.size() - 1)

func remove_tab(index:int) -> void:
	datas.remove_at(index)
	var tab_button:GUILibraryTabbarButton = _buttons_container.get_child(index)
	_buttons_container.remove_child(_buttons_container.get_child(index))
	tab_button.queue_free()
	var i:int = 0
	for top_bar_button:GUILibraryTabbarButton in _buttons_container.get_children():
		top_bar_button.action_evoked.disconnect(_on_tab_button_action_evoked)
		top_bar_button.action_evoked.connect(_on_tab_button_action_evoked.bind(i))
		i += 1
	if _buttons_container.get_child_count() == 0:
		all_tabs_cleared.emit()
	elif _buttons_container.get_child_count() > index:
		_on_tab_button_action_evoked(index)
	else:
		_on_tab_button_action_evoked(index-1)
		
func _on_tab_button_action_evoked(index:int) -> void:
	super._on_tab_button_action_evoked(index)
	tab_evoked.emit(datas[index])
		
