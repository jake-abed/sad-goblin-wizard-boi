extends State

@export var timer: Timer
@export var min_pause: float = 1.0
@export var max_pause: float = 2.0

func _ready() -> void:
	set_physics_process(false)
	timer.timeout.connect(_on_timer_timeout)

func enter_state() -> void:
	set_physics_process(true)
	timer.wait_time = randf_range(min_pause, max_pause)
	timer.start()

func exit_state() -> void:
	set_physics_process(false)

func _on_timer_timeout() -> void:
	state_finished.emit(self)
	timer.stop()
