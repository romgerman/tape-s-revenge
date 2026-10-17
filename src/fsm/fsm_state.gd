extends Node
class_name FSMState

var fsm: FSM

func _enter_tree() -> void:
	set_physics_process(false)
	set_process(false)
	set_process_input(false)

func enter() -> void:
	pass

func exit() -> void:
	pass
