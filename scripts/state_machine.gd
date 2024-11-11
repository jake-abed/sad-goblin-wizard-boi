class_name StateMachine extends Node

signal state_changed(prev: State, next: State)

@export var states: Array[State]
@export var current_state: State

func _ready() -> void:
	change_state(current_state)

func change_state(new_state: State) -> void:
	if current_state is State:
		state_changed.emit(current_state, new_state)
		current_state.exit_state()
	new_state.enter_state()
