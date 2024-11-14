extends Attack

@export var cooldown_timer: Timer

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

func attack() -> void:
	if not cooldown_timer.is_stopped():
		return
	var sparkle: Projectile = projectile.instantiate()
	sparkle = set_projectile_attributes(sparkle)
	get_tree().root.add_child(sparkle)
	cooldown_timer.start()

func set_projectile_attributes(projectile: Projectile) -> Projectile:
	projectile.damage = base_damage + player.attack / 2.0
	projectile.collision_radius = 12.0
	projectile.scale *= (1.0 + player.talent / 25.0)
	projectile.speed = base_speed + player.speed * 25.0
	projectile.global_position = spawn.global_position
	projectile.look_at(get_global_mouse_position())
	return projectile

func _on_cooldown_timeout() -> void:
	cooldown_timer.stop()
	var new_wait := 1.0 - (player.talent * 0.04)
	if new_wait <= 0.0:
		new_wait = 0.01
	cooldown_timer.wait_time = new_wait
