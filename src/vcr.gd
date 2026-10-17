extends Node3D

func _ready() -> void:
	await get_tree().create_timer(1.45 * 0.5).timeout
	var tw := create_tween().set_loops().set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "position", Vector3.UP * 0.02, 1.45)
	tw.tween_property(self, "position", -Vector3.UP * 0.02, 1.45)
	
