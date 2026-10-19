extends CharacterBody3D
class_name Enemy

@export var move_speed: float = 3.0
@export_range(0.0, 360, 0.01, "radians_as_degrees", "suffix:deg/s") var angular_speed: float = PI * 0.5

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Navigation
var target_position: Vector3 = Vector3.ZERO

# Stats
var health := EntityValue.create(100.0, 100.0)

func _ready() -> void:
	navigation_agent.velocity_computed.connect(_on_velocity_computed)

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
	
	var target_pos_2d := Vector3(target_position.x, 0.0, target_position.z)
	var current_pos_2d := Vector3(global_position.x, 0.0, global_position.z)
	var desired_velocity := (target_pos_2d - current_pos_2d).normalized() * move_speed
	
	#if Vector3(desired_velocity.x, 0, desired_velocity.z).length() > 0.001:
		#footsteps_fx()
	
	velocity = desired_velocity.limit_length(move_speed)
	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity()
	
	if not navigation_agent.avoidance_enabled:
		move_and_slide()
	else:
		navigation_agent.velocity = velocity

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	move_and_slide()

var navigation_was_complete := true

func set_target_position(target: Vector3) -> void:
	navigation_agent.target_position = target
	navigation_was_complete = false

func turn_towards(target_pos: Vector3, delta: float) -> void:
	var target_pos_flat := Vector3(target_pos.x, global_position.y, target_pos.z)
	
	if global_position.is_equal_approx(target_pos_flat):
		return
	
	if target_pos_flat.cross(Vector3.UP).length_squared() <= 0.00001:
		return
	
	var target_transform := global_transform.looking_at(target_pos_flat, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(target_transform.basis, delta * angular_speed).orthonormalized()

var damage_tw: Tween

func take_damage(dmg: Damage) -> void:
	velocity = velocity.lerp(
		dmg.position.direction_to(global_position) * Vector3(1, 0, 1) * 100.0,
		get_process_delta_time() * 10.0
	)
	move_and_slide()
	
	health.sub_value(dmg.value)
	
	if dmg.position != Vector3.ZERO:
		GameManager.show_damage_number(
			dmg.value,
			get_viewport().get_camera_3d().unproject_position(dmg.position),
			dmg.is_crit
		)
	else:
		GameManager.show_damage_number(
			dmg.value,
			get_viewport().get_camera_3d().unproject_position(get_parent_node_3d().global_position),
			dmg.is_crit
		)
	
	if health.value <= 0.0:
		GameManager.stats.enemies_killed += 1
		queue_free()
		return
	
	var player := AudioStreamPlayer3D.new()
	player.stream = load("res://assets/sounds/195952__minian89__swing_blood_splatter.mp3")
	add_child(player)
	player.play()
	player.finished.connect(func ():
		player.pitch_scale = randf_range(0.9, 1.1)
		player.queue_free()
	)
	
	if damage_tw:
		damage_tw.kill()
	
	damage_tw = create_tween()
	damage_tw.tween_property(self, "scale", Vector3.ONE * 0.9, 0.15).set_trans(Tween.TRANS_CUBIC)
	damage_tw.tween_property(self, "scale", Vector3.ONE * 1.0, 0.25).set_trans(Tween.TRANS_BACK)

# Handlers

func _on_hurt_box_hit(dmg: Damage) -> void:
	if dmg.owner != self:
		take_damage(dmg)
