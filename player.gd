extends CharacterBody2D

const SPEED = 125.0
const ACCEL = 15.0

@export var sprite: Sprite2D

@onready var gloob_tween := create_tween()
@onready var shoob_tween := create_tween()

func _ready() -> void:
	gloob_and_shoob()

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("swap_h"):
		global_position.x *= -1
	
	if Input.is_action_just_pressed("swap_v"):
		global_position.y *= -1
	
	var direction := Vector2(0, 0,)
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
	
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	if direction:
		velocity = velocity.lerp(direction * SPEED, ACCEL * delta)
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
	var target_y_scale = scale.y * 1.04
	var target_x_scale = scale.x * 1.07
	
	gloob_tween.set_loops()
	shoob_tween.set_loops()
	gloob_tween.set_trans(gloob_tween.TRANS_SINE)
	shoob_tween.set_trans(gloob_tween.TRANS_SINE)
	gloob_tween.set_ease(gloob_tween.EASE_IN_OUT)
	shoob_tween.set_ease(gloob_tween.EASE_IN_OUT)
	gloob_tween.tween_property(self, "scale:y", target_y_scale, 0.7)
	gloob_tween.tween_property(self, "scale:y", initial_scale.y, 0.5)
	shoob_tween.tween_property(self, "scale:x", target_x_scale, 0.4)
	shoob_tween.tween_property(self, "scale:x", initial_scale.x, 1.0)
