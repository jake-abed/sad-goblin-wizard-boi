class_name Attack extends Node2D

@export var player: Player
@export var spawn : Marker2D
@export var base_damage: float
@export var base_speed: float
@export var projectile: PackedScene

func attack() -> void:
	pass

func set_projectile_attributes(_projectile: Projectile) -> Projectile:
	return _projectile
