extends GameSession

@export var test_items:Array[ItemData]

#@onready var room: Room = $CombatScene/Room

#var _level:int = 1

func _ready() -> void:
	super._ready()
	start()
	for item_data:ItemData in test_items:
		item_inventory._obtain_item(item_data, 0)
	#Singletons.game_session = self
	#personal_count = PersonalCount.new()
	#combat_scene = $CombatScene
	#room.prepare()
	#combat_scene._current_room = room
	#Events.pollution_emitted.connect(_on_pollution_emitted)
	#Events.game_session_ready.emit(self)
	#var module_data:ModuleData = ModuleDatabase.get_data_by_id("cwahain_strike")
	#$CombatScene/Room/LootModule.item_data = module_data
	#$CombatScene/Room/PurchasableTrinket.trinket = TrinketSpawner.spawn_trinket(load("res://data/trinkets/trinket_tricksters_ring.tres"))
	

	#combat_scene.enter_floor()
