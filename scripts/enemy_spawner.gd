class_name EnemySpawner extends Node2D

@export var enemy: PackedScene
@export var level := 1

func pick_spawn_location() -> Vector2:
	var x := global_position.x + randi_range(-24, 24)
	var y := global_position.y + randi_range(-24, 24)
	return Vector2(x, y)

func spawn_enemy() -> void:
	var enemy_inst: Enemy = enemy.instantiate()
	enemy_inst.level = level
	enemy_inst.global_position = pick_spawn_location()
	get_tree().root.add_child(enemy_inst)
