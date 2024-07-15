@icon("res://addons/shaker/assets/ShakerType2D.svg")
@tool
class_name ShakerTypeBase2D
extends ShakerTypeBase

enum GraphAxis {
	X,
	Y,
}

@export var amplitude: Vector2 = Vector2.ONE:
	set = set_amplitude,
	get = get_amplitude

@export var offset: Vector2 = Vector2.ZERO:
	set = set_offset,
	get = get_offset

func set_amplitude(value: Vector2) -> void:
	amplitude = value
	_on_property_changed("amplitude")

func get_amplitude() -> Vector2:
	return amplitude

func set_offset(value: Vector2) -> void:
	offset = value
	_on_property_changed("offset")

func get_offset() -> Vector2:
	return offset

# Get the shake value at a given time
func get_value(t: float) -> Vector2:
	var result: Vector2 = Vector2.ZERO
	return _calc_value(fmod(t, 1.0), result)

# Calculate the shake value
func _calc_value(t: float, result: Vector2) -> Vector2:
	if duration > 0:
		t /= duration
	if (start_percent != 0 && start_percent > t) || (end_percent != 1 && end_percent < t):
		result = Vector2.ZERO
	else:
		result = result * amplitude + offset
		result *= (ease(t, fade_in) if fade_in > 0.0001 else 1.0) * (ease(1.0 - t, fade_out) if fade_out > 0.0001 else 1.0)
	return result
