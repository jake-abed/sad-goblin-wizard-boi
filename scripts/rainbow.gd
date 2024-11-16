extends Projectile

@export var collision: CollisionPolygon2D

var direction: Vector2
var hits: int = 3

func _ready() -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	body_entered.connect(_on_body_entered)
	grow()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(node: Node2D) -> void:
	if node is Player:
		return
	if node is Enemy:
		node.take_damage(damage)
	if hits <= 0:
		queue_free()
	else:
		hits -= 1

func grow() -> void:
	var target_scale := scale
	scale = target_scale * 0.01
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", target_scale, 0.25)
