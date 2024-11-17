class_name Game extends Node2D

@export var player: Player
@export var music: AudioStreamPlayer
@export var current_level: Level
@export var difficulty_level := 0
@export var reflection : Reflection
@onready var level_container := $Level

var pause_menu: PackedScene = preload("res://addons/maaacks_game_template/examples/scenes/overlaid_menus/pause_menu.tscn")

var levels_five: Array[PackedScene] = [
	
]
var levels_six: Array

var all_levels: Array[PackedScene] = [
	preload("res://scenes/levels/squares_level.tscn"),
	preload("res://scenes/levels/plus_level.tscn"),
	preload("res://scenes/levels/true_loop_level.tscn"),
	preload("res://scenes/levels/c_level.tscn"),
	preload("res://scenes/levels/hash_level.tscn"),
	preload("res://scenes/levels/bee_level.tscn")
]

func _ready() -> void:
	var level_scene = all_levels[difficulty_level]
	var level: Level = level_scene.instantiate()
	level.parent = self
	level.level_won.connect(_on_level_won)
	player.died.connect(_on_level_lost)
	reflection.dialog_chosen.connect(_on_dialog_chosen)
	current_level = level
	level_container.add_child(level)
	player.global_position = current_level.start_point.global_position
	music.play()

func _process(_d) -> void:
	if Input.is_action_just_pressed("pause"):
		$UI.add_child(pause_menu.instantiate())

func next_level() -> void:
	music.seek(0.0)
	raise_difficulty()
	current_level.queue_free()
	var level_scene = all_levels[difficulty_level]
	var level: Level = level_scene.instantiate()
	level.parent = self
	level.starting_difficulty = difficulty_level + 1
	clear_disposable_nodes()
	level.level_won.connect(_on_level_won)
	current_level = level
	level_container.add_child(level)
	player.global_position = current_level.start_point.global_position
	await reflection.dialog_chosen
	music.play()

func previous_level() -> void:
	music.seek(0.0)
	lower_difficulty()
	current_level.queue_free()
	var level_scene = all_levels[difficulty_level]
	var level: Level = level_scene.instantiate()
	level.parent = self
	level.starting_difficulty = difficulty_level + 1
	clear_disposable_nodes()
	level.level_won.connect(_on_level_won)
	current_level = level
	level_container.add_child(level)
	player.global_position = current_level.start_point.global_position
	player.current_health = player.max_health
	player.update_health_bar()
	player.reset_camera()
	await reflection.dialog_chosen
	player.is_dead = false
	player.can_move = true
	music.play()

func _on_level_lost() -> void:
	reflection.show()
	music.stop()
	get_tree().paused = true
	reflection.reset_after_death()
	previous_level()
	await reflection.dialog_chosen
	reflection.hide()
	get_tree().paused = false

func _on_level_won() -> void:
	reflection.show()
	music.stop()
	get_tree().paused = true
	reflection.reset_after_win()
	next_level()
	await reflection.dialog_chosen
	reflection.hide()
	get_tree().paused = false

func _on_dialog_chosen(result: String) -> void:
	handle_result(result)

func raise_difficulty() -> void:
	difficulty_level += 1
	if difficulty_level > 5:
		difficulty_level = 5

func lower_difficulty() -> void:
	difficulty_level -= 1
	if difficulty_level < 0:
		difficulty_level = 0

func handle_result(result: String) -> void:
	match result:
		"heal":
			player.heal()
		"nothing":
			pass
		"buff_speed":
			player.level_speed()
		"buff_heart":
			player.level_heart()
		"buff_attack":
			player.level_attack()
		"buff_reflection":
			player.level_reflection()
		"buff_talent":
			player.level_talent()
		"debuff_speed":
			player.level_speed()
		"debuff_heart":
			player.level_heart()
		"debuff_attack":
			player.level_attack()
		"debuff_reflection":
			player.level_reflection()
		"debuff_talent":
			player.level_talent()
		"win":
			player.level_speed()
			player.level_heart()
			player.level_attack()
			player.level_reflection()
			player.level_talent()
		_:
			pass

func clear_disposable_nodes() -> void:
	var enemies := get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.queue_free()
	var drops := get_tree().get_nodes_in_group("drops")
	for drop in drops:
		drop.queue_free()
	var projectiles := get_tree().get_nodes_in_group("projectiles")
	for projectile in projectiles:
		projectile.queue_free()
