class_name State extends Node

signal state_finished(state: State)

@export var actor: CharacterBody2D

func enter_state() -> void:
	pass

func exit_state() -> void:
	pass
