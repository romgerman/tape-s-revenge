@tool
extends Area3D
class_name HitBox

@export var damage: float = 10.0
@export var entity_owner: Node

func _ready() -> void:
	if not entity_owner:
		entity_owner = get_parent()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is HurtBox:
		area.take_damage(Damage.raw(damage).set_position(global_position).set_owner(entity_owner))

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		set_collision_layer_value(1, false)
		set_collision_layer_value(9, true)
		set_collision_mask_value(1, false)
		set_collision_mask_value(10, true)
