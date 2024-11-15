class_name Game extends Node2D

@export var music: AudioStreamPlayer

func _ready() -> void:
	music.play()
