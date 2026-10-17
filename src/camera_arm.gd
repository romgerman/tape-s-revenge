extends Node3D

@export var fsm: FSM
@export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var min_x := -PI * 0.5
@export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var max_x := -PI * 0.5
@export_group("Bob", "bob_")
@export var bob_idle_amplitude: float = 0.1
@export var bob_walk_amplitude: float = 0.1
@export var bob_sprint_amplitude: float = 0.1
@export var bob_idle_speed: float = 2.0
@export var bob_walk_speed: float = 2.0
@export var bob_sprint_speed: float = 2.0

var mouse_pos_rel := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var vp_t := get_tree().root.get_final_transform()
		var rel: Vector2 = event.xformed_by(vp_t).relative * GameManager.mouse_sensitivity
		mouse_pos_rel = rel

func _process(delta: float) -> void:
	bob(delta)
	rotate_camera()

func rotate_camera() -> void:
	rotate_x(-deg_to_rad(mouse_pos_rel.y))
	rotation.x = clampf(rotation.x, min_x, max_x)
	mouse_pos_rel = Vector2.ZERO

var bob_time := 0.0
var bob_speed := 0.0
var bob_amplitude := 0.0

func bob(delta: float) -> void:
	match fsm.get_current_state_name():
		&"Idle":
			bob_speed = lerpf(bob_speed, bob_idle_speed, delta * 5.0)
			bob_amplitude = lerpf(bob_amplitude, bob_idle_amplitude, delta * 5.0)
		&"Walk":
			bob_speed = lerpf(bob_speed, bob_walk_speed, delta * 5.0)
			bob_amplitude = lerpf(bob_amplitude, bob_walk_amplitude, delta * 5.0)
		&"Sprint":
			bob_speed = lerpf(bob_speed, bob_sprint_speed, delta * 5.0)
			bob_amplitude = lerpf(bob_amplitude, bob_sprint_amplitude, delta * 5.0)
	
	position.y = sin(bob_time) * bob_amplitude
	bob_time += delta * bob_speed
