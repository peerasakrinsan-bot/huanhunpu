class_name Combatant
extends RefCounted

var stats: CombatantStats
var hp: int
var qi: int
var action_meter: int = 0
var statuses: Array[StatusEffect] = []

func _init(base_stats: CombatantStats) -> void:
	stats = base_stats.duplicate_stats()
	hp = stats.max_hp
	qi = 0

func is_alive() -> bool:
	return hp > 0

func gain_qi(amount: int) -> void:
	qi = clampi(qi + amount, 0, stats.max_qi)

func spend_qi(amount: int) -> bool:
	if qi < amount:
		return false
	qi -= amount
	return true

func take_damage(raw_damage: int) -> int:
	var mitigated: int = maxi(1, raw_damage - int(stats.defense * 0.5))
	hp = maxi(0, hp - mitigated)
	return mitigated

func take_pure_damage(amount: int) -> void:
	hp = maxi(0, hp - amount)

func add_status(kind: StatusEffect.Kind, stacks: int) -> void:
	for effect in statuses:
		if effect.kind == kind:
			effect.stacks += stacks
			return
	statuses.append(StatusEffect.new(kind, stacks))

func tick_statuses() -> Array[String]:
	var messages: Array[String] = []
	for effect in statuses.duplicate():
		var message := effect.tick(self)
		if not message.is_empty():
			messages.append(message)
		if effect.is_expired():
			statuses.erase(effect)
	return messages

func status_text() -> String:
	if statuses.is_empty():
		return "None"
	var labels: Array[String] = []
	for effect in statuses:
		labels.append(effect.get_label())
	return ", ".join(labels)
