extends FSMState

@export var attack_range: float = 2.0
@export var visual: Node3D

var update_tw: Tween

func enter() -> void:
	visual.play_walk()
	update_tw = create_tween().set_loops()
	update_tw.tween_callback(func ():
		if GameManager.player:
			fsm.get_owner_entity().set_target_position(GameManager.player.global_position)
	).set_delay(0.5)

func exit() -> void:
	if update_tw:
		update_tw.kill()

func _physics_process(delta: float) -> void:
	var enemy: Enemy = fsm.get_owner_entity()
	enemy.turn_towards(enemy.target_position, delta)
	
	if enemy.global_position.distance_to(GameManager.player.global_position) <= attack_range:
		fsm.change_state_to(^"Attack")
