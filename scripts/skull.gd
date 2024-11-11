class_name Skull extends Enemy

const BASE_SPEED := 125.0

@export var wander_state: State


func _ready() -> void:
	wander_state.state_finished.connect(_on_wander_finished)
	print("Skull ready!")
	
func _on_wander_finished() -> void:
	pass
