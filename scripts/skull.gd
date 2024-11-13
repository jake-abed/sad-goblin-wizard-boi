class_name Skull extends Enemy

const BASE_SPEED := 100.0
const BASE_HP := 10.0
const BASE_ATTACK := 1.0

@export var wander_state: State
@export var pause_state: State
@export var chasing_state: State
@export var contact_area: Area2D
@export var level := 1

@onready var shadow := $Shadow

var target: Player
var speed: float
var health: float
var attack: float

func _ready() -> void:
	contact_area.body_entered.connect(_on_body_entered)
	contact_area.body_exited.connect(_on_body_exited)
	wander_state.state_finished.connect(_on_wander_finished)
	pause_state.state_finished.connect(_on_pause_finished)
	set_stats()
	animate()
	print("Skull ready!")

func set_stats() -> void:
	speed = BASE_SPEED + level * 25.0
	health = BASE_HP + level * 1.0
	attack = BASE_ATTACK + level

func animate() -> void:
	var rotate_tween := create_tween()
	var squash_tween := create_tween()
	var initial_y_scale := sprite.scale.y
	
	rotate_tween.set_ease(Tween.EASE_IN_OUT)
	rotate_tween.set_trans(Tween.TRANS_SINE)
	squash_tween.set_ease(Tween.EASE_IN_OUT)
	squash_tween.set_trans(Tween.TRANS_SINE)
	
	rotate_tween.set_loops(0)
	rotate_tween.set_parallel(false)
	squash_tween.set_loops(0)
	squash_tween.set_parallel(false)
	
	rotate_tween.tween_property(sprite, "rotation_degrees", 5, 0.6)
	rotate_tween.tween_property(sprite, "rotation_degrees", -5, 0.6)
	squash_tween.tween_property(sprite, "scale:y", initial_y_scale * 0.95, 0.75)
	squash_tween.tween_property(sprite, "scale:y", initial_y_scale * 1.01, 0.75)

func take_damage(damage: float) -> void:
	health -= damage
	if health <= 0.0:
		queue_free()

func _on_body_entered(node: Node2D) -> void:
	if node is not Player:
		return
	else:
		target = node
		state_machine.change_state(chasing_state)

func _on_body_exited(node: Node2D) -> void:
	if node is not Player:
		return
	else:
		target = null
		state_machine.change_state(pause_state)

func _on_wander_finished(_state: State) -> void:
	if target:
		state_machine.change_state(chasing_state)
	else:
		state_machine.change_state(pause_state)

func _on_pause_finished(_state: State) -> void:
	if target:
		state_machine.change_state(chasing_state)
	else:
		state_machine.change_state(wander_state)
