extends Node3D

@export var attack_speed: float = 0.3
@export var entity_owner: Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: HitBox = $HitBox
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var sfx_idle: AudioStreamPlayer3D = $Idle
@onready var sfx_rewind: AudioStreamPlayer3D = $Rewind

var initial_rotation := Vector3.ZERO

func _ready() -> void:
	initial_rotation = rotation
	hitbox.entity_owner = entity_owner
	
	animation_player.play(&"Idle")
	
	await get_tree().create_timer(1.45 * 0.5).timeout
	var tw := create_tween().set_loops().set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "position", Vector3.UP * 0.02, 1.45)
	tw.tween_property(self, "position", -Vector3.UP * 0.02, 1.45)

var attack_timer := 0.0
var attack_rotation := Vector3.ZERO

func _physics_process(_delta: float) -> void:
	rotation = rotation.slerp(initial_rotation + attack_rotation, _delta * 5.0)

	if Time.get_ticks_msec() > attack_timer and is_attacking:
		hitbox.monitoring = not hitbox.monitoring
		attack_timer = Time.get_ticks_msec() + attack_speed * 1000.0
	
	if hitbox.monitoring and hitbox.has_overlapping_areas():
		for area: HurtBox in hitbox.get_overlapping_areas():
			if area.get_parent() != GameManager.player:
				particles.visible = hitbox.has_overlapping_areas()

var is_attacking := false

func attack() -> void:
	is_attacking = true
	attack_rotation = Vector3(0.0, PI * 0.5, 0.0)
	sfx_idle.stream_paused = true
	sfx_rewind.play()

func unattack() -> void:
	is_attacking = false
	hitbox.monitoring = false
	attack_rotation = Vector3.ZERO
	particles.visible = false
	sfx_idle.stream_paused = false
	sfx_rewind.stop()
