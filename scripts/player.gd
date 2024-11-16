class_name Player extends CharacterBody2D

const ACCEL = 15.0
const BASE_SPEED := 150.0

@export_category("Connected Nodes")
@export var camera: Camera2D
@export var sprite: Sprite2D
@export var wand: Sprite2D
@export var anim_player: AnimationPlayer
@export var current_attack: Attack
@export var secondary_attack: Attack
@export var hurtbox: Area2D
@export var health_bar: TextureProgressBar

@export_category("Stats - S.H.A.R.T.")
@export var speed := 1.0
@export var heart := 1.0
@export var attack := 1.0
@export var reflection := 1.0
@export var talent := 1.0

@onready var gloob_tween := create_tween()
@onready var shoob_tween := create_tween()
@onready var teleport_particles_scene := preload("res://scenes/teleport_particles.tscn")
@onready var level_up_control := %LevelUpControl
@onready var speed_button := %SpeedButton
@onready var speed_level_label := %SpeedLevelLabel
@onready var heart_button := %HeartButton
@onready var heart_level_label := %HeartLevelLabel
@onready var attack_button := %AttackButton
@onready var attack_level_label := %AttackLevelLabel
@onready var reflection_button := %ReflectionButton
@onready var reflection_level_label := %ReflectionLevelLabel
@onready var talent_button := %TalentButton
@onready var talent_level_label := %TalentLevelLabel

var max_health := heart
var current_health := max_health
var current_speed := (25.0 * speed) + BASE_SPEED
var can_move := true
var is_dead := false

## For leveling first level should take 10 xp and an additional 10 xp per level
var level := 1
var xp := 0.0
var xp_to_next_level := 10

func _ready() -> void:
	speed_button.pressed.connect(level_speed)
	heart_button.pressed.connect(level_heart)
	attack_button.pressed.connect(level_attack)
	reflection_button.pressed.connect(level_reflection)
	talent_button.pressed.connect(level_talent)
	update_health_bar()
	gloob_and_shoob()

func _physics_process(delta: float) -> void:
	
	wand.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("level_up"):
		level_up()
	
	if Input.is_action_just_pressed("horizontal_teleport") and can_move:
		reflect_h()
	
	if Input.is_action_just_pressed("vertical_teleport") and can_move:
		reflect_v()
	
	if Input.is_action_pressed("primary_attack"):
		current_attack.attack()
	
	if Input.is_action_pressed("secondary_attack"):
		secondary_attack.attack()
	
	var direction := Vector2(0, 0,)
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	# This is kind of brittle, but it controls both the position and orientation
	# of the wand and player sprite direction as they turn.
	if direction.x > 0:
		sprite.flip_h = false
		wand.position.x = -76
	elif direction.x < 0:
		sprite.flip_h = true
		wand.position.x = 52
	
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
	var initial_scale = sprite.scale
	var target_y_scale = initial_scale.y * 0.96
	var target_x_scale = initial_scale.x * 1.05
	
	gloob_tween.set_loops()
	shoob_tween.set_loops()
	gloob_tween.set_trans(gloob_tween.TRANS_SINE)
	shoob_tween.set_trans(gloob_tween.TRANS_SINE)
	gloob_tween.set_ease(gloob_tween.EASE_IN_OUT)
	shoob_tween.set_ease(gloob_tween.EASE_IN_OUT)
	gloob_tween.tween_property(sprite, "scale:y", target_y_scale, 0.7)
	gloob_tween.tween_property(sprite, "scale:y", initial_scale.y, 0.4)
	shoob_tween.tween_property(sprite, "scale:x", target_x_scale, 0.4)
	shoob_tween.tween_property(sprite, "scale:x", initial_scale.x, 0.7)

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

func take_damage(damage: float) -> void:
	current_health -= damage
	camera.add_trauma(damage * 3)
	print("Took " + str(damage) + " damage. " + str(current_health) + " remains.")
	update_health_bar()
	if current_health <= 0.0:
		hide()
		camera.trauma_power = 0.0
		camera.trauma = 0
		is_dead = true
		can_move = false
		$CollisionShape2D.call_deferred("set_disabled", true)

func update_health_bar() -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health

func gain_xp(amount: float) -> void:
	xp += amount
	if xp >= xp_to_next_level:
		level_up()
		xp_to_next_level += level * 10

func level_speed() -> void:
	speed += 1.0
	speed_level_label.text = str(speed)
	current_speed = (25.0 * speed) + BASE_SPEED
	get_tree().paused = false
	level_up_control.hide()

func level_heart() -> void:
	heart += 1.0
	heart_level_label.text = str(heart)
	max_health += 1.0
	current_health += 1.0
	update_health_bar()
	get_tree().paused = false
	level_up_control.hide()

func level_attack() -> void:
	attack += 1.0
	attack_level_label.text = str(attack)
	get_tree().paused = false
	level_up_control.hide()

func level_reflection() -> void:
	reflection += 1.0
	reflection_level_label.text = str(reflection)
	get_tree().paused = false
	level_up_control.hide()

func level_talent() -> void:
	talent += 1.0
	talent_level_label.text = str(talent)
	get_tree().paused = false
	level_up_control.hide()

func level_up() -> void:
	get_tree().paused = true
	level += 1
	level_up_control.show()
