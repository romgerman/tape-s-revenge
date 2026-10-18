extends Marker3D

@export var delay: float = 3.0
@export var max_enemies: int = 20

const EnemyScene := preload("res://scenes/enemy.tscn")

var delay_timer := 0.0
var enemy_count := 0

func _physics_process(delta: float) -> void:
	if Time.get_ticks_msec() > delay_timer and enemy_count < max_enemies:
		var enemy := EnemyScene.instantiate()
		enemy.tree_exiting.connect(_on_enemy_tree_exiting)
		add_child(enemy)
		enemy_count += 1
		delay_timer = Time.get_ticks_msec() + delay * 1000.0

func _on_enemy_tree_exiting() -> void:
	enemy_count -= 1
