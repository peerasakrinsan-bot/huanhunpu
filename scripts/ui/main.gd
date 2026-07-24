extends Control

@onready var engine: CombatEngine = $CombatEngine
@onready var title_label: Label = %TitleLabel
@onready var player_label: Label = %PlayerLabel
@onready var enemy_label: Label = %EnemyLabel
@onready var queue_label: Label = %QueueLabel
@onready var status_label: Label = %StatusLabel
@onready var log_label: RichTextLabel = %LogLabel
@onready var basic_button: Button = %BasicButton
@onready var art_button: Button = %ArtButton
@onready var focus_button: Button = %FocusButton

var log_lines: Array[String] = []

func _ready() -> void:
	engine.log_added.connect(_on_log_added)
	engine.state_changed.connect(_refresh)
	engine.combat_finished.connect(_on_combat_finished)
	basic_button.pressed.connect(engine.use_basic_attack)
	art_button.pressed.connect(engine.use_blood_art)
	focus_button.pressed.connect(engine.use_focus)
	engine.start_stage_one()

func _refresh() -> void:
	var enemy: Combatant = engine.get_active_enemy()
	player_label.text = "%s\nHP %d/%d   Qi %d/%d" % [engine.player.stats.display_name, engine.player.hp, engine.player.stats.max_hp, engine.player.qi, engine.player.stats.max_qi]
	if enemy == null:
		enemy_label.text = "Enemy Queue Cleared"
		status_label.text = "Status Effects: %s" % engine.player.status_text()
	else:
		enemy_label.text = "%s\nHP %d/%d" % [enemy.stats.display_name, enemy.hp, enemy.stats.max_hp]
		status_label.text = "Player: %s\nEnemy: %s" % [engine.player.status_text(), enemy.status_text()]
	queue_label.text = "Turn Queue: " + " → ".join(engine.get_turn_preview()) + "\nEnemies: " + _enemy_queue_text()
	basic_button.disabled = not engine.waiting_for_player
	focus_button.disabled = not engine.waiting_for_player
	art_button.disabled = not engine.waiting_for_player or engine.player.qi < 3 or engine.player.hp <= 10

func _enemy_queue_text() -> String:
	var names: Array[String] = []
	for index: int in range(engine.active_enemy_index, engine.enemies.size()):
		var enemy: Combatant = engine.enemies[index]
		if enemy.is_alive():
			names.append(enemy.stats.display_name)
	return " → ".join(names)

func _on_log_added(message: String) -> void:
	log_lines.append(message)
	if log_lines.size() > 12:
		log_lines.pop_front()
	log_label.text = "\n".join(log_lines)
	_refresh()

func _on_combat_finished(victory: bool) -> void:
	title_label.text = "Stage 1 Victory" if victory else "Soul Returns to Sect"
	basic_button.disabled = true
	art_button.disabled = true
	focus_button.disabled = true
	_refresh()
