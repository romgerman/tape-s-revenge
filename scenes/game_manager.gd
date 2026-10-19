extends Node3D

class Stats:
	var enemies_killed: int = 0:
		set(value):
			enemies_killed = value
			changed.emit()
	var elapsed: float = 0.0:
		set(value):
			elapsed = value
			changed.emit()
	
	signal changed()
	
	func reset() -> void:
		enemies_killed = 0
		elapsed = 0.0

@export var mouse_sensitivity : float = 0.25
@export var damage_numbers: CanvasLayer
@export var label_settings: LabelSettings

var player: Player
var stats := Stats.new()
var level_is_going := false

signal player_died()

func start_level() -> void:
	stats.reset()
	level_is_going = true

func end_level() -> void:
	level_is_going = false

func _physics_process(delta: float) -> void:
	if level_is_going:
		stats.elapsed += delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func show_damage_number(value: float, pos: Vector2, is_crit: bool = false) -> void:
	var number = Label.new()
	number.position = pos
	number.text = "%d" % floor(value)
	number.modulate = Color.TRANSPARENT
	number.label_settings = label_settings

	damage_numbers.add_child.call_deferred(number)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "modulate", Color.WHITE if not is_crit else Color.YELLOW, 0.25
	)
	if is_crit:
		tween.tween_property(
			number, "scale", Vector2.ONE * 2.0, 0.25
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel(false).tween_property(
			number, "scale", Vector2.ONE * 1, 0.25
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		number, "position:y", number.position.y - 24.0, 0.25
	)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_delay(0.25)
	tween.set_parallel(false).tween_property(
		number, "modulate", Color.TRANSPARENT, 0.25
	)

	await tween.finished
	number.queue_free()
