extends CharacterBody3D
class_name Player

const BloodParticlesScene := preload("res://scenes/blood_particles.tscn")

@export var walk_speed: float = 3.0
@export var sprint_speed: float = 5.0
@export_flags_3d_physics var attack_ray_layer: int

@onready var right_arm_weapon: Node3D = $CameraPivot/CameraArm/Camera3D/RightArmPivot/vhs_tape
@onready var left_arm_weapon: Node3D = $CameraPivot/CameraArm/Camera3D/LeftArmPivot/vcr
@onready var health_bar: Range = $UI/MarginContainer/Health
@onready var stats_label: RichTextLabel = $UI/MarginContainer/Stats/StatsLabel

# Stats
var health := EntityValue.create(100.0, 100.0)

func _enter_tree() -> void:
	GameManager.player = self

func _ready() -> void:
	health_bar.value = health.value
	health.changed.connect(_on_health_changed)
	_on_stats_changed()
	GameManager.stats.changed.connect(_on_stats_changed)

func _on_health_changed(value: float) -> void:
	health_bar.value = value

func _on_stats_changed() -> void:
	stats_label.text = "Enemies killed: %s\nTime survived: %0.1fs" % [
		GameManager.stats.enemies_killed,
		GameManager.stats.elapsed
	]

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
	elif Input.is_action_just_pressed("attack_secondary_2"):
		attack_right_2()
	
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
	if not attack_right_1_finished or not attack_right_2_finished:
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
		var dir := ray.from.direction_to(hit["position"])
		right_arm_weapon.target_reached.connect(func ():
			var raw_damage := randf_range(10.0, 30.0)
			var dmg := Damage.raw(raw_damage).set_position(hit["position"]).set_owner(self)
			if raw_damage >= 20.0:
				dmg.set_is_crit(true)
			enemy_hurtbox.take_damage(dmg)
			var blood := BloodParticlesScene.instantiate() as Node3D
			enemy_hurtbox.add_child(blood)
			blood.global_position = hit["position"] - dir
			await get_tree().create_timer(0.35).timeout
			if is_instance_valid(blood):
				blood.queue_free()
		, CONNECT_ONE_SHOT)
		await right_arm_weapon.attack(hit["position"])
		attack_right_1_finished = true

var attack_right_2_finished := true

func attack_right_2() -> void:
	if not attack_right_2_finished or not attack_right_1_finished:
		return
	
	attack_right_2_finished = false
	
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
		attack_right_2_finished = true
	else:
		var enemy_hurtbox := hit["collider"] as HurtBox
		right_arm_weapon.target_reached.connect(func ():
			var enemy := enemy_hurtbox.get_parent_node_3d() as Enemy
			var dir := ray.from.direction_to(hit["position"])
			var tw := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
			tw.tween_property(enemy, "global_position", global_position + dir * 2.0, 0.5)
		, CONNECT_ONE_SHOT)
		await right_arm_weapon.attack(hit["position"])
		attack_right_2_finished = true

func attack_left(toggle: bool) -> void:
	if toggle:
		left_arm_weapon.attack()
	else:
		left_arm_weapon.unattack()

func take_damage(dmg: Damage) -> void:
	health.sub_value(dmg.value)
	
	if health.value <= 0.0:
		GameManager.player_died.emit()
		return

func _on_hurt_box_hit(dmg: Damage) -> void:
	if dmg.owner != self:
		take_damage(dmg)
