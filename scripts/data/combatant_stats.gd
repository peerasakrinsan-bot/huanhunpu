class_name CombatantStats
extends Resource

@export var display_name: String = "Wanderer"
@export var max_hp: int = 100
@export var max_qi: int = 6
@export var attack: int = 12
@export var defense: int = 4
@export var speed: int = 10
@export var is_player: bool = false

func duplicate_stats() -> CombatantStats:
	var copy: CombatantStats = CombatantStats.new()
	copy.display_name = display_name
	copy.max_hp = max_hp
	copy.max_qi = max_qi
	copy.attack = attack
	copy.defense = defense
	copy.speed = speed
	copy.is_player = is_player
	return copy
