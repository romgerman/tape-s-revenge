extends Node3D

func _ready() -> void:
	var tw := create_tween().set_loops().set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "position", Vector3.UP * 0.04, 1.45)
	tw.tween_property(self, "position", -Vector3.UP * 0.04, 1.45)
	
