@tool
extends Area3D
class_name HurtBox

signal hit(dmg: Damage)

func take_damage(dmg: Damage) -> void:
	hit.emit(dmg)

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		set_collision_layer_value(1, false)
		set_collision_layer_value(10, true)
		set_collision_mask_value(1, false)
		set_collision_mask_value(9, true)
