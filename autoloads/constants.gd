extends Node

const MAX_SKILLS := 10
const MAX_DEPTHS := 5
const MAX_TURNS := 1
const STARTING_GEM := 0
const SHAPE_UNIT_SIZE := 16.0
const NORMAL_INDICATOR_ALPHA := 0.8

const DEAD_CIVILIAN_TO_LOSE := 15

const MINIMUM_AUDIO := -20
const MAXIMUM_AUDIO := 20
const MAX_GAME_SPEED := 3
const MIN_GAME_SPEED := 1

var TELEGRAPHING_MOVES := false

const GROUP_COMBAT_INDICATOR := "combat_indicator"

const COLOR_RED := Color("ff0040")
const COLOR_RED1 := Color("f5555d")
const COLOR_RED2 := Color("ea323c")
const COLOR_RED3 := Color("c42430")
const COLOR_RED4 := Color("891e2b")
const COLOR_RED5 := Color("571c27")
const COLOR_YELLOW1 := Color("ffeb57")
const COLOR_YELLOW2 := Color("ffc825")
const COLOR_YELLOW3 := Color("ffa214")
const COLOR_BLUE_4 := Color("0098dc")
const COLOR_BLUE_5 := Color("00396d")
const COLOR_BLUE_3 := Color("00cdf9")
const COLOR_BLUE_2 := Color("0cf1ff")
const COLOR_BLUE_1 := Color("94fdff")
const COLOR_DARK_DARK_BLUE := Color("03193f")
const COLOR_GREEN1 := Color("d3fc7e")
const COLOR_GREEN2 := Color("99e65f")
const COLOR_GREEN3 := Color("5ac54f")
const COLOR_GREEN4 := Color("33984b")
const COLOR_GREEN5 := Color("1e6f50")
const COLOR_GREEN6 := Color("134c4c")
const COLOR_GREEN7 := Color("0c2e44")
const COLOR_ORANGE1 := Color("ed7614")
const COLOR_ORANGE2 := Color("ff5000")
const COLOR_ORANGE3 := Color("C64524")
const COLOR_ORANGE4 := Color("8e251d")
const COLOR_RED_PURPLE1 := Color("ca52c9")
const COLOR_RED_PURPLE2 := Color("93388f")
const COLOR_RED_PURPLE3 := Color("622461")
const COLOR_RED_PURPLE4 := Color("3b1443")
const COLOR_PURPLE0 := Color("fdd2ed")
const COLOR_PURPLE1 := Color("f389f5")
const COLOR_PURPLE2 := Color("db3ffd")
const COLOR_PURPLE3 := Color("7a09fa")
const COLOR_BEIGE_1 := Color("f9e6cf")
const COLOR_BEIGE_2 := Color("f6ca9f")
const COLOR_BEIGE_3 := Color("e69c69")
const PURPLE4 := Color("3b1443")
const COLOR_WHITE := Color.WHITE
const COLOR_BLUE_GRAY_1:= Color("c7cfdd")
const COLOR_BLUE_GRAY_2 := Color("92a1b9")
const COLOR_BLUE_GRAY_3 := Color("424c6e")
const COLOR_BLUE_GRAY_4 := Color("2a2f4e")
const COLOR_BLUE_GRAY_5 := Color("1a1932")
const COLOR_BLUE_GRAY_6 := Color("0e071b")
const COLOR_GRAY1 := Color("b4b4b4")
const COLOR_GRAY2 := Color("858585")
const COLOR_GRAY3 := Color("5d5d5d")
const COLOR_GRAY4 := Color("3d3d3d")
const COLOR_GRAY5 := Color("272727")
const COLOR_GRAY6 := Color("1b1b1b")
const COLOR_DARK_GRAY := Color("272727")
const COLOR_BROWN_2 := Color("8a4836")
const COLOR_BROWN_3 := Color("5d2c28")
const COLOR_BROWN_4 := Color("391f21")
const COLOR_BROWN_5 := Color("1c121c")
const COLOR_BLACK := Color("131313")
const COLOR_RED_PURPLE_3 := Color("93388f")

const LIGHT_THEME_COLOR = COLOR_YELLOW2
const WATER_THEME_COLOR = COLOR_BLUE_3

const COLOR_PLAYER := COLOR_BLUE_4
const COLOR_ENEMY := COLOR_RED3

const CHARACTER_Z_INDEX := 5
const GROUND_Z_INDEX := 0


const HEALTH_PER_INDICATOR := 5
const MAX_ITEM_SLOTS_IN_INVENTORY := 36
const MAX_INVENTORY_WIDTH := 6
const MAX_INVENTORY_HEIGHT := 6

const COMMON_C0LOR := Constants.COLOR_BEIGE_1
const UNCOMMON_COLOR := Constants.COLOR_GREEN2
const RARE_COLOR := Constants.COLOR_BLUE_3

const TOOLTIP_HIGHLIGHT_COLOR_GREEN := Constants.COLOR_GREEN2
const TOOLTIP_HIGHLIGHT_COLOR_PURPLE := Constants.COLOR_PURPLE1
const TOOLTIP_HIGHLIGHT_COLOR_RED := Constants.COLOR_RED2

# Mob Addons

# GUI
const ICON_CONTAINER_SCENE = preload("res://scenes/GUI/utils/gui_icon_container.tscn")

const projectile_outline := false

# Animation
const FIELD_STATUS_HOOK_ANIMATION_DURATION := 0.4
const CARD_ANIMATION_DELAY := 0.1
const PLANT_SEED_ANIMATION_TIME := 0.3

var ON_PUSH_PARTICLE = load("res://scenes/utils/visual_effects/impact_particle.tscn")
var MOB_DEATH_PARTICLE = load("res://scenes/utils/visual_effects/mob_on_death_particle.tscn")
var BLOOD_PARTICLE = load("res://scenes/utils/visual_effects/blood_particle.tscn")

const INPUT_TEXTURE = preload("res://resources/sprites/GUI/icons/controls/input_icons.png")

const SHORT_CUT_ICONS := {
	"end_turn": Vector2i(22, 3),
	"undo_move":Vector2i(10, 2),
	"action_1": Vector2i(17, 1),
	"action_2": Vector2i(18, 1),
	"action_3": Vector2i(19, 1),
	"action_4": Vector2i(20, 1),
	"action_5": Vector2i(21, 1),
	"action_q": Vector2i(17, 2),
	"action_w": Vector2i(18, 2),
	"action_e": Vector2i(19, 2),
}

const BUTTON_NORMAL_COLOR := Constants.COLOR_BROWN_3
const BUTTON_PRESSED_COLOR := Constants.COLOR_BROWN_4
const BUTTON_HOVERED_COLOR := Constants.COLOR_BROWN_2
const BUTTON_DISABLED_COLOR := Constants.COLOR_GRAY5
const BUTTON_SELECTED_COLOR := Constants.COLOR_RED_PURPLE3

const MENU_BUTTON_NORMAL_COLOR := Constants.COLOR_YELLOW3
const MENU_BUTTON_HOVERED_COLOR := Constants.COLOR_YELLOW1
const MENU_BUTTON_PRESSED_COLOR := Constants.COLOR_ORANGE4
const MENU_BUTTON_DISABLED_COLOR := Constants.COLOR_GRAY1
const MENU_BUTTON_SELECTED_COLOR := Constants.COLOR_BLUE_3

const HP_RECOVER_COLOR := Constants.COLOR_GREEN3
const HP_REDUCE_COLOR := Constants.COLOR_RED2
const SHIELD_REDUCE_COLOR := Constants.COLOR_BLUE_3
const SHIELD_RECOVER_COLOR := Constants.COLOR_BLUE_2

const DEFAULT_ORDER_INDEX := -99 # 99 is the default value, which is reserved for player controlled character
const DEFAULT_INDICATOR_COLOR := Constants.COLOR_YELLOW1 # 99 is the default value, which is reserved for player controlled character

const INDICATOR_COLOR := {
	0: Color("ff004d"), # Bright red
	1: Color("7bff00"), # Lime
	2: Color("b14cff"), # Purple
	3: Color("29adff"), # Sky blue
	4: Color("ff6c24"), # Orange
	5: Color("ff4dae"), # Pink
}

var TEST_DISPLAYING_SEQUENCE:Array[int] = []
#var TEST_DISPLAYING_SEQUENCE:Array[int] = [0, 1, 2, 3, 5, 6 ,7, 8, 10, 11, 12, 13, 15, 16, 17, 18, 20, 21, 22, 23, 24]
# var TEST_DISPLAYING_SEQUENCE := [0, 5, 10, 15, 21, 22, 23, 24, 20] # Left column then bottom row, double bingo.
#var TEST_DISPLAYING_SEQUENCE := [20, 21, 22, 23, 19, 18, 17, 16, 24, 15] # Bottom row
#var TEST_DISPLAYING_SEQUENCE := [2, 7, 12, 17, 22] # Column 3


# 1: Color("00b543"), # Bright green
