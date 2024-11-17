extends State

var destination: Vector2
var direction: Vector2
var tick_interval := randi_range(12, 18)
var tick := 0

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if tick_interval == tick:
		tick = 0
		destination = actor.target.global_position
		direction = actor.global_position.direction_to(destination)
	if actor.global_position.distance_to(destination) < 400.0:
		actor.velocity *= 0.0
	else:
		actor.velocity = actor.velocity.lerp(direction * 1.1 * actor.speed, 5.0 * delta)
	tick += 1
	actor.move_and_slide()

func enter_state() -> void:
	if !actor.target or actor.target is not Player:
		exit_state()
		state_finished.emit(self)
		return
	destination = actor.target.global_position
	direction = actor.global_position.direction_to(destination)
	set_physics_process(true)

func exit_state() -> void:
	set_physics_process(false)
