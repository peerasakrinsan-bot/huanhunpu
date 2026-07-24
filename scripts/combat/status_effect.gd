class_name StatusEffect
extends RefCounted

enum Kind { INTERNAL_WOUND, POISON }

var kind: Kind
var stacks: int
var duration: int

func _init(effect_kind: Kind, effect_stacks: int, effect_duration: int = -1) -> void:
	kind = effect_kind
	stacks = effect_stacks
	duration = effect_duration

func get_label() -> String:
	match kind:
		Kind.INTERNAL_WOUND:
			return "Internal Wound x%d" % stacks
		Kind.POISON:
			return "Poison x%d" % stacks
	return "Unknown"

func tick(target: Combatant) -> String:
	match kind:
		Kind.INTERNAL_WOUND:
			var wound_damage: int = stacks
			target.take_pure_damage(wound_damage)
			return "%s bleeds internally for %d." % [target.stats.display_name, wound_damage]
		Kind.POISON:
			var poison_damage: int = stacks * 2
			target.take_pure_damage(poison_damage)
			stacks = max(0, stacks - 1)
			return "%s suffers %d poison damage." % [target.stats.display_name, poison_damage]
	return ""

func is_expired() -> bool:
	return stacks <= 0 or duration == 0
