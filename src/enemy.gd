extends CharacterBody3D

@export var move_speed: float = 3.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Navigation
var target_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity()
	
	# Check if we are at the target
	if not navigation_agent.is_navigation_finished():
		target_position = navigation_agent.get_next_path_position()
	else:
		if not navigation_was_complete:
			navigation_was_complete = true
		
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
	
	# Do not take into account Y axis because navmesh doesn't follow the real geometry
	var target_pos_2d := Vector3(target_position.x, 0.0, target_position.z)
	var current_pos_2d := Vector3(global_position.x, 0.0, global_position.z)
	var desired_velocity := (target_pos_2d - current_pos_2d).normalized() * move_speed
	
	#if Vector3(desired_velocity.x, 0, desired_velocity.z).length() > 0.001:
		#footsteps_fx()
	
	velocity = desired_velocity.limit_length(move_speed)
	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity()
	
	move_and_slide()

var navigation_was_complete := true

func set_target_position(target: Vector3) -> void:
	navigation_agent.target_position = target
	navigation_was_complete = false
