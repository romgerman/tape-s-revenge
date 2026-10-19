extends FSMState

@export var visual: Node3D
@export var hitbox: HitBox

func enter() -> void:
	await get_tree().create_timer(0.5).timeout
	visual.play_attack()
	await get_tree().create_timer(0.1).timeout
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.1).timeout
	hitbox.monitoring = false
	
	fsm.change_state_to(^"Chase")
