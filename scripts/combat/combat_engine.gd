class_name CombatEngine
extends Node

signal state_changed
signal log_added(message: String)
signal combat_finished(victory: bool)

const METER_READY: int = 100

var player: Combatant
var enemies: Array[Combatant] = []
var active_enemy_index: int = 0
var waiting_for_player: bool = false
var current_actor: Combatant

func start_stage_one() -> void:
	player = Combatant.new(_make_stats("Blood Sword Disciple", 112, 8, 18, 5, 13, true))
	enemies = [
		Combatant.new(_make_stats("Hungry Jiangshi", 44, 0, 10, 2, 8)),
		Combatant.new(_make_stats("Poison Marauder", 58, 2, 12, 3, 11)),
		Combatant.new(_make_stats("Demon Blade Adept", 76, 4, 16, 5, 12)),
	]
	active_enemy_index = 0
	waiting_for_player = false
	current_actor = null
	_log("Blood Sword Sect enters the forbidden valley.")
	_advance_until_player_choice()

func use_basic_attack() -> void:
	if not waiting_for_player:
		return
	var enemy: Combatant = get_active_enemy()
	var dealt: int = enemy.take_damage(player.stats.attack)
	enemy.add_status(StatusEffect.Kind.INTERNAL_WOUND, 1)
	_log("Blood Slash deals %d and adds Internal Wound." % dealt)
	_finish_actor_turn()

func use_blood_art() -> void:
	if not waiting_for_player or player.qi < 3 or player.hp <= 10:
		return
	var enemy: Combatant = get_active_enemy()
	player.spend_qi(3)
	player.take_pure_damage(8)
	var dealt: int = enemy.take_damage(int(player.stats.attack * 2.0))
	enemy.add_status(StatusEffect.Kind.INTERNAL_WOUND, 2)
	_log("Blood Debt Sword costs 8 HP and 3 Qi, dealing %d." % dealt)
	_finish_actor_turn()

func use_focus() -> void:
	if not waiting_for_player:
		return
	player.gain_qi(3)
	_log("Focused breathing restores 3 Qi.")
	_finish_actor_turn()

func get_active_enemy() -> Combatant:
	if active_enemy_index >= enemies.size():
		return null
	return enemies[active_enemy_index]

func get_turn_preview(count: int = 4) -> Array[String]:
	var preview: Array[String] = []
	var simulated: Array[Combatant] = []
	if player != null and player.is_alive():
		simulated.append(player)
	var active_enemy: Combatant = get_active_enemy()
	if active_enemy != null and active_enemy.is_alive():
		simulated.append(active_enemy)
	var meters: Dictionary[Combatant, int] = {}
	for combatant: Combatant in simulated:
		meters[combatant] = combatant.action_meter
	while preview.size() < count and not simulated.is_empty():
		for combatant: Combatant in simulated:
			meters[combatant] += combatant.stats.speed
			if meters[combatant] >= METER_READY:
				meters[combatant] -= METER_READY
				preview.append(combatant.stats.display_name)
				if preview.size() == count:
					break
	return preview

func _advance_until_player_choice() -> void:
	while player.is_alive() and get_active_enemy() != null:
		var actors: Array[Combatant] = [player, get_active_enemy()]
		for actor: Combatant in actors:
			actor.action_meter += actor.stats.speed
			if actor.action_meter >= METER_READY:
				actor.action_meter -= METER_READY
				current_actor = actor
				for message: String in actor.tick_statuses():
					_log(message)
				if not actor.is_alive():
					_check_enemy_queue()
					continue
				if actor.stats.is_player:
					waiting_for_player = true
					state_changed.emit()
					return
				_enemy_action(actor)
				_check_finished()
	waiting_for_player = false
	_check_finished()
	state_changed.emit()

func _enemy_action(enemy: Combatant) -> void:
	var dealt: int = player.take_damage(enemy.stats.attack)
	if enemy.stats.display_name == "Poison Marauder":
		player.add_status(StatusEffect.Kind.POISON, 2)
		_log("%s strikes for %d and applies Poison." % [enemy.stats.display_name, dealt])
	else:
		_log("%s attacks for %d." % [enemy.stats.display_name, dealt])

func _finish_actor_turn() -> void:
	waiting_for_player = false
	_check_enemy_queue()
	_check_finished()
	_advance_until_player_choice()

func _check_enemy_queue() -> void:
	while get_active_enemy() != null and not get_active_enemy().is_alive():
		_log("%s falls. Next enemy steps forward." % get_active_enemy().stats.display_name)
		active_enemy_index += 1

func _check_finished() -> void:
	if not player.is_alive():
		combat_finished.emit(false)
	elif get_active_enemy() == null:
		combat_finished.emit(true)

func _make_stats(name: String, hp: int, max_qi: int, attack: int, defense: int, speed: int, is_player: bool = false) -> CombatantStats:
	var stats: CombatantStats = CombatantStats.new()
	stats.display_name = name
	stats.max_hp = hp
	stats.max_qi = max_qi
	stats.attack = attack
	stats.defense = defense
	stats.speed = speed
	stats.is_player = is_player
	return stats

func _log(message: String) -> void:
	log_added.emit(message)
