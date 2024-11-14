class_name Projectile extends Area2D

@export var collision: CollisionShape2D
@export var life_time: Timer

@onready var collision_radius: float = collision.shape.radius

var damage: float
var speed: float
var size_scaling: float
