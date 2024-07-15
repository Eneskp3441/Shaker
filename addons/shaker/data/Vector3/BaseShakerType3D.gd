@icon("res://addons/shaker/assets/ShakerType3D.svg")
@tool
class_name ShakerTypeBase3D
extends ShakerTypeBase

enum GraphAxis {
	X,
	Y,
	Z
}

@export var amplitude: Vector3 = Vector3.ONE:
	set = set_amplitude,
	get = get_amplitude

@export var offset: Vector3 = Vector3.ZERO:
	set = set_offset,
	get = get_offset

func set_amplitude(value: Vector3) -> void:
	amplitude = value
	_on_property_changed("amplitude")

func get_amplitude() -> Vector3:
	return amplitude

func set_offset(value: Vector3) -> void:
	offset = value
	_on_property_changed("offset")

func get_offset() -> Vector3:
	return offset

# Get the shake value at a given time
func get_value(t: float) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	return _calc_value(fmod(t, 1.0), result)

# Calculate the shake value
func _calc_value(t: float, result: Vector3) -> Vector3:
	if duration > 0:
		t /= duration
	if (start_percent != 0 && start_percent > t) || (end_percent != 1 && end_percent < t):
		result = Vector3.ZERO
	else:
		result = result * amplitude + offset
		result *= (ease(t, fade_in) if abs(fade_in) > 0.0001 else 1.0) * (ease(1.0 - t, fade_out) if abs(fade_out) > 0.0001 else 1.0)
	return result
