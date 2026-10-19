extends RefCounted
class_name Damage

var value: float
var position: Vector3
var owner: Node
var is_crit: bool

func set_position(p: Vector3) -> Damage:
	self.position = p
	return self

func set_owner(o: Node) -> Damage:
	self.owner = o
	return self

func set_is_crit(_is_crit: bool) -> Damage:
	self.is_crit = _is_crit
	return self

static func raw(damage: float) -> Damage:
	var instance := Damage.new()
	instance.value = damage
	return instance
