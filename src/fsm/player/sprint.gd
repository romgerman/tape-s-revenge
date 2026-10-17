extends FSMState

func _input(event: InputEvent) -> void:
	if event.is_action_released("sprint"):
		fsm.change_state_to(^"Walk")

func _physics_process(_delta: float) -> void:
	if fsm.get_owner_entity().velocity.length() < 0.001:
		fsm.change_state_to(^"Idle")
