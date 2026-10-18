extends CharacterBody3D
class_name Player

@export var walk_speed: float = 3.0
@export var sprint_speed: float = 5.0
@export_flags_3d_physics var attack_ray_layer: int

@onready var right_arm_weapon: Node3D = $CameraPivot/CameraArm/Camera3D/RightArmPivot/vhs_tape
@onready var left_arm_weapon: Node3D = $CameraPivot/CameraArm/Camera3D/LeftArmPivot/vcr

# Stats
var health := EntityValue.create(100.0, 100.0)

func _enter_tree() -> void:
	GameManager.player = self

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var dir := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	if not is_on_floor():
		velocity = get_gravity()
	
	if is_on_floor():
		if Input.is_action_pressed("sprint"):
			velocity = dir * sprint_speed
		else:
			velocity = dir * walk_speed
	
	move_and_slide()

func _process(_delta: float) -> void:
	rotate_around()
	
	if Input.is_action_just_pressed("attack_primary"):
		attack_right_1()
	
	if Input.is_action_pressed("attack_secondary_1"):
		attack_left(true)
	else:
		attack_left(false)

var mouse_pos_rel := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var vp_t := get_tree().root.get_final_transform()
		var rel: Vector2 = event.xformed_by(vp_t).relative * GameManager.mouse_sensitivity
		mouse_pos_rel = rel

func rotate_around() -> void:
	rotate_y(-deg_to_rad(mouse_pos_rel.x))
	mouse_pos_rel = Vector2.ZERO

var attack_right_1_finished := true

func attack_right_1() -> void:
	if not attack_right_1_finished:
		return
	
	attack_right_1_finished = false
	
	var space_state := get_world_3d().direct_space_state
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	
	var ray := PhysicsRayQueryParameters3D.new()
	ray.collision_mask = attack_ray_layer
	ray.from = camera.project_ray_origin(viewport.get_visible_rect().get_center())
	ray.to = ray.from + camera.project_ray_normal(viewport.get_visible_rect().get_center()) * 100.0
	ray.exclude = [self]
	ray.collide_with_areas = true
	ray.collide_with_bodies = false
	
	var hit := space_state.intersect_ray(ray)
	
	if not hit:
		await right_arm_weapon.attack(ray.from + camera.project_ray_normal(viewport.get_visible_rect().get_center()) * 10.0)
		attack_right_1_finished = true
	else:
		var enemy_hurtbox := hit["collider"] as HurtBox
		right_arm_weapon.target_reached.connect(enemy_hurtbox.take_damage.bind(Damage.raw(20.0)), CONNECT_ONE_SHOT)
		await right_arm_weapon.attack(hit["position"])
		attack_right_1_finished = true

func attack_left(toggle: bool) -> void:
	if toggle:
		left_arm_weapon.attack()
	else:
		left_arm_weapon.unattack()
