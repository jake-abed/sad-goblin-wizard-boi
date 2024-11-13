extends Projectile

var direction: Vector2

func _ready() -> void:
	spin()
	direction = Vector2.RIGHT.rotated(rotation)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(node: Node2D) -> void:
	if node is Player:
		return
	if node is Enemy:
		node.take_damage(damage)
	queue_free()

func spin() -> void:
	var tween := create_tween()
	tween.set_loops(0)
	tween.set_parallel(false)
	tween.tween_property($Sprite2D, "rotation_degrees", 360, 0.5)
	tween.tween_property($Sprite2D, "rotation_degrees", 0, 0.0)
