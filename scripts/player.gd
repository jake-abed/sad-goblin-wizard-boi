class_name Player extends CharacterBody2D

const ACCEL = 15.0
const BASE_SPEED := 125.0

@export var sprite: Sprite2D
@export var wand: Sprite2D
@export var anim_player: AnimationPlayer
@export var current_attack: Attack

@export var speed := 5.0
@export var health := 5.0
@export var attack := 5.0
@export var reflection := 5.0
@export var toughness := 5.0
@export var max_health := health

@onready var gloob_tween := create_tween()
@onready var shoob_tween := create_tween()
@onready var teleport_particles_scene := preload("res://scenes/teleport_particles.tscn")

var current_health := max_health
var current_speed := (5.0 * speed) + BASE_SPEED
var can_move := true

func _ready() -> void:
	gloob_and_shoob()

func _physics_process(delta: float) -> void:
	
	wand.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("swap_h") and can_move:
		reflect_h()
	
	if Input.is_action_just_pressed("swap_v") and can_move:
		reflect_v()
	
	if Input.is_action_pressed("primary_attack"):
		current_attack.attack()
	
	var direction := Vector2(0, 0,)
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	if direction.x > 0:
		sprite.scale.x = 0.25
	elif direction.x < 0:
		sprite.scale.x = -0.25
	
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	if direction && can_move:
		velocity = velocity.lerp(direction * current_speed, ACCEL * delta)
		if (!gloob_tween.is_running() or !shoob_tween.is_running()):
			gloob_tween.play()
			shoob_tween.play()
	else:
		velocity = velocity.lerp(Vector2(0.0, 0.0), ACCEL * delta)
		if (gloob_tween.is_running() or shoob_tween.is_running()):
			gloob_tween.stop()
			shoob_tween.stop()
	move_and_slide()

func gloob_and_shoob() -> void:
	var initial_scale = scale
	var target_y_scale = scale.y * 0.97
	var target_x_scale = scale.x * 1.03
	
	gloob_tween.set_loops()
	shoob_tween.set_loops()
	gloob_tween.set_trans(gloob_tween.TRANS_SINE)
	shoob_tween.set_trans(gloob_tween.TRANS_SINE)
	gloob_tween.set_ease(gloob_tween.EASE_IN_OUT)
	shoob_tween.set_ease(gloob_tween.EASE_IN_OUT)
	gloob_tween.tween_property(self, "scale:y", target_y_scale, 0.7)
	gloob_tween.tween_property(self, "scale:y", initial_scale.y, 0.4)
	shoob_tween.tween_property(self, "scale:x", target_x_scale, 0.4)
	shoob_tween.tween_property(self, "scale:x", initial_scale.x, 0.7)

func reflect_h() -> void:
	can_move = false
	anim_player.stop()
	anim_player.play("teleport_away")
	create_teleport_particles()
	await anim_player.animation_finished
	global_position.x *= -1
	create_teleport_particles()
	anim_player.play("teleport_in")
	await anim_player.animation_finished
	can_move = true

func reflect_v() -> void:
	can_move = false
	anim_player.stop()
	anim_player.play("teleport_away")
	create_teleport_particles()
	await anim_player.animation_finished
	global_position.y *= -1
	create_teleport_particles()
	anim_player.play("teleport_in")
	can_move = true

func create_teleport_particles() -> void:
	var teleport_particles: GPUParticles2D = teleport_particles_scene.instantiate()
	teleport_particles.global_position = global_position
	teleport_particles.restart()
	self.get_parent().add_child(teleport_particles)
