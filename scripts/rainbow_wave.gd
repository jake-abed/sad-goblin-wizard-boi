extends Attack

@export var cooldown_timer: Timer

func _ready() -> void:
	cooldown_timer.wait_time = 1.5 - log(player.talent) / log(169.0)
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

func attack() -> void:
	if not cooldown_timer.is_stopped():
		return
	var sparkle: Projectile = projectile.instantiate()
	sparkle = set_projectile_attributes(sparkle)
	get_tree().root.add_child(sparkle)
	cooldown_timer.start()

# P is not the best name, but we're keeping this terse here.
func set_projectile_attributes(p: Projectile) -> Projectile:
	p.damage = base_damage + player.attack / 2.0
	p.scale *= (1.0 + player.talent / 50.0)
	p.speed = base_speed + player.speed * 25.0
	p.global_position = spawn.global_position
	p.look_at(get_global_mouse_position())
	return p

func _on_cooldown_timeout() -> void:
	cooldown_timer.stop()
	var new_wait := 1.5 - log(2 * player.talent) / log(70.0)
	if new_wait <= 0.0:
		new_wait = 0.01
	cooldown_timer.wait_time = new_wait