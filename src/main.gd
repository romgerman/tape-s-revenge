extends Node3D

@onready var died_screen: Control = $UI/DiedScreen
@onready var player_spawn: Node3D = $Level/PlayerSpawn

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.player_died.connect(_on_player_died)
	GameManager.start_level()

func _on_player_died() -> void:
	GameManager.end_level()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	died_screen.visible = true

func _on_restart_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.player.queue_free()
	for e in get_tree().get_nodes_in_group("entity:enemy"):
		e.queue_free()
	var player = load("res://scenes/player.tscn").instantiate()
	player_spawn.add_child(player)
	GameManager.start_level()
	get_tree().paused = false
	died_screen.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
