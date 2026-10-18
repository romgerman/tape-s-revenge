extends Node3D

@onready var tape: Node3D = $tape

signal target_reached()

func _ready() -> void:
	var tw := create_tween().set_loops().set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "position", Vector3.UP * 0.04, 1.45)
	tw.tween_property(self, "position", -Vector3.UP * 0.04, 1.45)
	
	tape.target_reached.connect(target_reached.emit)

func attack(target_position: Vector3) -> void:
	await tape.set_target_position(target_position)
