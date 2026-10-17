extends CharacterBody3D

@export var walk_speed: float = 3.0
@export var sprint_speed: float = 5.0

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

var mouse_pos_rel := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var vp_t := get_tree().root.get_final_transform()
		var rel: Vector2 = event.xformed_by(vp_t).relative * GameManager.mouse_sensitivity
		mouse_pos_rel = rel

func rotate_around() -> void:
	rotate_y(-deg_to_rad(mouse_pos_rel.x))
	mouse_pos_rel = Vector2.ZERO
