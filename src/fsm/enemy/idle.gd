extends FSMState

func enter() -> void:
	fsm.change_state_to(^"Chase")
