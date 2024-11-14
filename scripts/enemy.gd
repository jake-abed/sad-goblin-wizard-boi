class_name Enemy extends CharacterBody2D

@export var sprite: Sprite2D
@export var state_machine: StateMachine
@export var xp: PackedScene

func take_damage(_damage: float) -> void:
	pass
