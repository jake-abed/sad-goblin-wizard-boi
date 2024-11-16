extends State

@export var wander_marker: Marker2D
@export var wander_pivot: Node2D
@export var timer: Timer

var destination: Vector2
var direction: Vector2

func _ready() -> void:
	set_physics_process(false)
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float) -> void:
	actor.velocity = actor.velocity.lerp(Vector2.ZERO, delta)
	actor.move_and_slide()

func enter_state() -> void:
	set_physics_process(true)
	choose_wander_target()
	timer.wait_time = randf_range(1.25, 1.75)
	timer.start()

func exit_state() -> void:
	set_physics_process(false)

func choose_wander_target() -> void:
	var random_angle := deg_to_rad(randi_range(0,360))
	wander_pivot.rotate(random_angle)
	destination = wander_marker.global_position
	direction = actor.global_position.direction_to(destination)
	actor.velocity = direction * actor.speed * randf_range(0.97, 1.05)

func _on_timer_timeout() -> void:
	direction = Vector2.ZERO
	state_finished.emit(self)
	timer.stop()
