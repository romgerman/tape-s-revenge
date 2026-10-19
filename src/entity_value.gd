extends RefCounted
class_name EntityValue

var value: float
var max_value: float

signal changed(value: float)

func set_value(val: float) -> void:
	value = minf(val, max_value)
	changed.emit(value)

func add_value(val: float) -> void:
	value = minf(value + val, max_value)
	changed.emit(value)

func sub_value(val: float) -> void:
	value = minf(value - val, max_value)
	changed.emit(value)

static func create(val: float, max_val: float) -> EntityValue:
	var instance := EntityValue.new()
	instance.value = val
	instance.max_value = max_val
	return instance
