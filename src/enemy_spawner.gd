extends Marker3D

@export var delay: float = 3.0

const EnemyScene := preload("res://scenes/enemy.tscn")

var delay_timer := 0.0

func _physics_process(delta: float) -> void:
	if Time.get_ticks_msec() > delay_timer:
		var enemy := EnemyScene.instantiate()
		add_child(enemy)
		delay_timer = Time.get_ticks_msec() + delay * 1000.0
