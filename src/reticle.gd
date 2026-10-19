@tool
extends Control

func _draw() -> void:
	var rect := get_rect()
	
	draw_circle(
		rect.get_center(),
		3.0,
		Color.WHITE,
		true,
		-1.0,
		true
	)
