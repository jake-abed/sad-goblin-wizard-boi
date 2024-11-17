extends Control

@onready var skip := $Button
@onready var anims := $AnimationPlayer
@onready var audio := $AudioStreamPlayer

func _ready() -> void:
	anims.animation_finished.connect(_on_anim_finished)
	skip.pressed.connect(_on_skip_pressed)
	anims.play("scroll_up")
	audio.play()

func load_game():
	SceneLoader.load_scene("res://scenes/game.tscn")

func _on_skip_pressed() -> void:
	audio.stop()
	load_game()
	await SceneLoader.scene_loaded
	queue_free()

func _on_anim_finished(anim) -> void:
	audio.stop()
	load_game()
	await SceneLoader.scene_loaded
	queue_free()
	
