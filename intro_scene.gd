extends Control

@onready var skip := $Button
@onready var anims := $AnimationPlayer

func _ready() -> void:
	anims.animation_finished.connect(_on_anim_finished)
	skip.pressed.connect(_on_skip_pressed)
	anims.play("scroll_up")

func load_game():
	SceneLoader.load_scene("res://scenes/game.tscn")

func _on_skip_pressed() -> void:
	load_game()

func _on_anim_finished(anim) -> void:
	load_game()
