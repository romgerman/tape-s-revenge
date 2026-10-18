extends RefCounted
class_name Damage

var value: float
var position: Vector3

func set_position(p: Vector3) -> Damage:
	self.position = p
	return self

static func raw(damage: float) -> Damage:
	var instance := Damage.new()
	instance.value = damage
	return instance
