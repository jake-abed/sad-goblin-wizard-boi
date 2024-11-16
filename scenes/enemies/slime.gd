class_name Slime extends Enemy

const BASE_SPEED := 300.0
const BASE_HP := 3.0
const BASE_ATTACK := 1.0

@export var wander_state: State
@export var pause_state: State
@export var level := 1
@export var xp_val := 5.0
@export var hitbox_radius := 19.0
@export var hitbox_height := 56.0

@onready var shadow := $Shadow
@onready var hitbox := $HitBox
@onready var hitbox_shape: CapsuleShape2D = $HitBox/CollisionShape2D.shape
@onready var hitbox_timer := $HitBox/Timer
@onready var contact_area := $ContactArea
@onready var projectile := preload("res://scenes/attacks/pellet.tscn")

var target: Player
var speed: float
var health: float
var attack: float
var attack_timer: Timer

func _ready() -> void:
	hitbox.area_entered.connect(_on_hitbox_entered)
	hitbox_timer.timeout.connect(_on_hitbox_timeout)
	wander_state.state_finished.connect(_on_wander_finished)
	pause_state.state_finished.connect(_on_pause_finished)
	contact_area.body_entered.connect(_on_contact_entered)
	contact_area.body_exited.connect(_on_contact_exited)
	hitbox_shape.radius = hitbox_radius
	set_stats()
	if level >= 3:
		attack_timer = Timer.new()
		attack_timer.wait_time = 1.5
		attack_timer.timeout.connect(_on_attack_timeout)
		add_child(attack_timer)
	animate()

func set_stats() -> void:
	speed = BASE_SPEED + level * 10.0
	health = BASE_HP + level
	attack = (BASE_ATTACK + level) / 10.0

func animate() -> void:
	var squash_x_tween := create_tween()
	var squash_tween := create_tween()
	var initial_x_scale := sprite.scale.x
	var initial_y_scale := sprite.scale.y
	
	squash_x_tween.set_ease(Tween.EASE_IN_OUT)
	squash_x_tween.set_trans(Tween.TRANS_SINE)
	squash_tween.set_ease(Tween.EASE_IN_OUT)
	squash_tween.set_trans(Tween.TRANS_SINE)
	
	squash_x_tween.set_loops(0)
	squash_x_tween.set_parallel(false)
	squash_tween.set_loops(0)
	squash_tween.set_parallel(false)
	
	squash_x_tween.tween_property(sprite, "scale:x", initial_x_scale * 1.07 , 0.75)
	squash_x_tween.tween_property(sprite, "scale:x", initial_x_scale * 0.97 , 0.75)
	squash_tween.tween_property(sprite, "scale:y", initial_y_scale * 0.93, 0.75)
	squash_tween.tween_property(sprite, "scale:y", initial_y_scale * 1.03, 0.75)

func take_damage(damage: float) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_parallel(false)
	var sprite_scale := sprite.scale
	tween.tween_property(sprite, "scale", sprite_scale * (1 - (damage * 0.03)), 0.1)
	tween.tween_property(sprite, "scale", sprite_scale, 0.1)
	health -= damage
	if health <= 0.0:
		var xp_scene: Xp = xp.instantiate()
		xp_scene.value = xp_val * level
		xp_scene.global_position = global_position
		get_tree().root.call_deferred("add_child", xp_scene)
		queue_free()

func exec_attack() -> void:
	var p: Projectile = projectile.instantiate()
	p.global_position = global_position
	p.damage = 0.2 * level
	p.look_at(target.global_position)
	p.speed = 200.0 + level * 50.0
	get_tree().root.add_child(p)

func _on_wander_finished(_state: State) -> void:
	state_machine.change_state(pause_state)

func _on_pause_finished(_state: State) -> void:
	state_machine.change_state(wander_state)

func _on_hitbox_entered(node: Node) -> void:
	if node is HurtBox && node.get_parent() is Player:
		node.get_parent().take_damage(attack)
		hitbox_shape.radius = 0.01
		hitbox_shape.height = 0.01
		hitbox_timer.start()
		state_machine.change_state(pause_state)

func _on_hitbox_timeout() -> void:
	hitbox_shape.radius = hitbox_radius
	hitbox_shape.height = hitbox_height
	hitbox_timer.stop()

func _on_contact_entered(node: Node2D) -> void:
	if node is Player:
		target = node
		if attack_timer:
			attack_timer.start()

func _on_contact_exited(node: Node2D) -> void:
	if node is Player:
		target = null
		if attack_timer:
			attack_timer.stop()

func _on_attack_timeout() -> void:
	exec_attack()
	attack_timer.start()
