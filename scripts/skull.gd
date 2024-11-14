class_name Skull extends Enemy

const BASE_SPEED := 100.0
const BASE_HP := 10.0
const BASE_ATTACK := 1.0

@export var wander_state: State
@export var pause_state: State
@export var chasing_state: State
@export var contact_area: Area2D
@export var level := 1
@export var hitbox_radius := 25.0

@onready var shadow := $Shadow
@onready var hitbox := $HitBox
@onready var hitbox_shape: CircleShape2D = $HitBox/CollisionShape2D.shape
@onready var hitbox_timer := $HitBox/Timer

var target: Player
var speed: float
var health: float
var attack: float


func _ready() -> void:
	contact_area.body_entered.connect(_on_body_entered)
	contact_area.body_exited.connect(_on_body_exited)
	hitbox.area_entered.connect(_on_hitbox_entered)
	hitbox_timer.timeout.connect(_on_hitbox_timeout)
	wander_state.state_finished.connect(_on_wander_finished)
	pause_state.state_finished.connect(_on_pause_finished)
	hitbox_shape.radius = hitbox_radius
	set_stats()
	animate()

func set_stats() -> void:
	speed = BASE_SPEED + level * 10.0
	health = BASE_HP + level * 2.0
	attack = BASE_ATTACK + level - 1.0

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
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_parallel(false)
	var sprite_scale := sprite.scale
	tween.tween_property(sprite, "scale", sprite_scale * (1 - (damage * 0.03)), 0.1)
	tween.tween_property(sprite, "scale", sprite_scale, 0.1)
	health -= damage
	if health <= 0.0:
		var xp: Xp = xp.instantiate()
		xp.global_position = global_position
		get_tree().root.call_deferred("add_child", xp)
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

func _on_hitbox_entered(node: Node) -> void:
	if node is HurtBox && node.get_parent() is Player:
		node.get_parent().take_damage(attack)
		hitbox_shape.radius = 0.01
		hitbox_timer.start()
		state_machine.change_state(pause_state)

func _on_hitbox_timeout() -> void:
	hitbox_shape.radius = hitbox_radius
	hitbox_timer.stop()
