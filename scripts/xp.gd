class_name Xp extends Area2D

@export var value := 10.0
@export var sprite: Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	play_float()

func play_float() -> void:
	var initial_scale = sprite.scale
	var float_tween := create_tween()
	var scale_tween := create_tween()
	float_tween.set_ease(Tween.EASE_IN_OUT)
	float_tween.set_trans(Tween.TRANS_SINE)
	float_tween.set_parallel(false)
	float_tween.set_loops(0)
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.set_parallel(false)
	scale_tween.set_loops(0)
	
	float_tween.tween_property(sprite, "position:y", sprite.position.y - 1.5, 0.85)
	float_tween.tween_property(sprite, "position:y", sprite.position.y + 1.5, 0.85)
	scale_tween.tween_property(sprite, "scale", initial_scale * 1.05, 0.65)
	scale_tween.tween_property(sprite, "scale", initial_scale * 0.95, 0.65)

func _on_body_entered(node: Node2D) -> void:
	if node is Player:
		node.gain_xp(value)
		queue_free()
