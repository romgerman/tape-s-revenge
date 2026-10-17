extends Node
class_name FSM

@export var initial_state: FSMState

var blackboard: Dictionary = {}
var current_state: FSMState

func _ready() -> void:
	blackboard.set("_owner_entity", get_parent())
	
	if initial_state:
		change_state(initial_state)
	
	for state: FSMState in get_children():
		state.fsm = self

func change_state_to(path: NodePath) -> void:
	change_state(get_node(path))

func change_state(new_state: FSMState) -> void:
	if current_state:
		_disable_state(current_state)
		current_state.exit()
	
	current_state = new_state
	
	current_state.fsm = self
	current_state.enter()
	_enable_state(current_state)

func get_owner_entity() -> CharacterBody3D:
	return blackboard.get("_owner_entity", null)

func get_current_state_name() -> StringName:
	if current_state:
		return current_state.name
	else:
		return StringName()

func _enable_state(state: FSMState) -> void:
	state.set_physics_process(true)
	state.set_process(true)
	state.set_process_input(true)

func _disable_state(state: FSMState) -> void:
	state.set_physics_process(false)
	state.set_process(false)
	state.set_process_input(false)
