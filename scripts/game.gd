class_name Game extends Node2D

@export var player: Player
@export var music: AudioStreamPlayer
@export var current_level: Level
@export var possible_levels: Array[PackedScene]

@onready var level_container := $Level

func _ready() -> void:
	music.play()
	var level: Level = possible_levels.pick_random().instantiate()
	level.level_ended.connect(_on_level_ended)
	current_level = level
	level_container.add_child(level)
	player.global_position = current_level.start_point.global_position

func _on_level_ended() -> void:
	next_level()

func next_level() -> void:
	music.stop()
	music.seek(0.0)
	current_level.queue_free()
	var level: Level = possible_levels.pick_random().instantiate()
	var enemies := get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.queue_free()
	var drops := get_tree().get_nodes_in_group("drops")
	for drop in drops:
		drop.queue_free()
	level.level_ended.connect(_on_level_ended)
	current_level = level
	level_container.add_child(level)
	player.global_position = current_level.start_point.global_position
	music.play()
