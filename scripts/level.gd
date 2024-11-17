class_name Level extends Node2D

signal level_won

@export var start_point: Marker2D
@export var level_timer: Timer
@export var spawn_timer: Timer
@export var difficulty_timer: Timer
@export var starting_difficulty: int = 1
@export var difficulty_interval: float = 20.0
@export var timer_label: Label
@export_range(1.5, 5.0, 0.05) var average_spawn_time: float = 5.0
@export_range(40.0, 120.0, 20.0) var level_length: float = 60.0

var parent: Game
var spawner_groups: Array[Node]

func _ready() -> void:
	spawner_groups = get_tree().get_nodes_in_group("spawner_group")
	for spawner_group in spawner_groups:
		var spawners := spawner_group.get_children()
		for spawner in spawners:
			spawner.level = starting_difficulty
	level_length = 30.0 + 15.0 * starting_difficulty
	if level_length > 120.0:
		level_length = 120.0
	level_timer.wait_time = level_length
	difficulty_timer.wait_time = difficulty_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)
	level_timer.timeout.connect(_on_level_timer_timeout)
	spawn_timer.start()
	difficulty_timer.start()
	level_timer.start()

func _process(_d) -> void:
	timer_label.text = "%02d:%02d" % time_left()

func update_spawner_groups() -> void:
	spawner_groups = get_tree().get_nodes_in_group("spawner_group")

func time_left() -> Array[int]:
	var time := level_timer.time_left
	var minute: int = floor(time / 60)
	var second := int(time) % 60
	return [minute, second]

func _on_spawn_timer_timeout() -> void:
	update_spawner_groups()
	for spawner_group in spawner_groups:
		var spawners := spawner_group.get_children()
		var spawn: EnemySpawner = spawners.pick_random()
		spawn.spawn_enemy()
	spawn_timer.wait_time = randf_range(average_spawn_time - 0.25, average_spawn_time + 0.25)
	spawn_timer.start()

func _on_difficulty_timer_timeout() -> void:
	for spawner_group in spawner_groups:
		var spawners := spawner_group.get_children()
		for spawner in spawners:
			spawner.level += 1
	average_spawn_time -= average_spawn_time / 10.0
	difficulty_timer.start()

func _on_level_timer_timeout() -> void:
	level_won.emit()
