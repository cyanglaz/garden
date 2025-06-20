class_name GUIEnemyIconButton
extends GUIBasicButton

@onready var _gui_character_icon: GUICharacterIcon = %GUICharacterIcon
@onready var _death_mark: TextureRect = %DeathMark

var combat_state:Enemy.CombatState = Enemy.CombatState.INACTIVE : set = _set_combat_state	

func _ready() -> void:
	super._ready()
	pivot_offset = size/2
	_death_mark.hide()

func bind_enemy(enemy:Enemy) -> void:
	_gui_character_icon.bind_character(enemy.data)
	enemy.combat_state_changed.connect(_on_combat_state_changed)
	combat_state = enemy.combat_state

func _set_button_state(state:ButtonState) -> void:
	super._set_button_state(state)
	scale = Vector2.ONE
	match state:
		ButtonState.HOVERED:
			_gui_character_icon.add_outline(Constants.COLOR_PURPLE2)
			scale = Vector2(1.1, 1.1)
		ButtonState.PRESSED:
			_gui_character_icon.add_outline(Constants.COLOR_PURPLE3)
		ButtonState.NORMAL:
			if mouse_in:
				_gui_character_icon.add_outline(Constants.COLOR_PURPLE2)
			else:
				_gui_character_icon.remove_outline()
		ButtonState.DISABLED:
			_gui_character_icon.remove_outline()
		ButtonState.SELECTED:
			_gui_character_icon.remove_outline()
	if state != ButtonState.HOVERED:
		_set_combat_state(combat_state)

func _on_combat_state_changed(cs:Enemy.CombatState) -> void:
	self.combat_state = cs

func _set_combat_state(val:Enemy.CombatState) -> void:
	combat_state = val
	match combat_state:
		Enemy.CombatState.INACTIVE:
			_gui_character_icon.self_modulate = Constants.COLOR_GRAY1
		Enemy.CombatState.ACTIVE:
			_gui_character_icon.add_outline(Constants.COLOR_PURPLE0)
			_gui_character_icon.self_modulate = Constants.COLOR_WHITE
		Enemy.CombatState.DEAD:
			_death_mark.show()
			_gui_character_icon.self_modulate = Constants.COLOR_GRAY3
