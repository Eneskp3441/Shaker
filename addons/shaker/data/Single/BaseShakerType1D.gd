@icon("res://addons/shaker/assets/ShakerType.svg")
@tool
class_name ShakerTypeBase1D
extends ShakerTypeBase

enum GraphAxis {
	X,
}

@export var amplitude:float = 1.0:
	set = set_amplitude,
	get = get_amplitude

@export var offset:float = 0.0:
	set = set_offset,
	get = get_offset

func set_amplitude(value: float) -> void:
	amplitude = value
	_on_property_changed("amplitude")

func get_amplitude() -> float:
	return amplitude

func set_offset(value: float) -> void:
	offset = value
	_on_property_changed("offset")

func get_offset() -> float:
	return offset

# Get the shake value at a given time
func get_value(t: float) -> float:
	var result:float = 0.0;
	return _calc_value(fmod(t, 1.0), result)

# Calculate the shake value
func _calc_value(t: float, result: float) -> float:
	if duration > 0:
		t /= duration
	if (start_percent != 0 && start_percent > t) || (end_percent != 1 && end_percent < t):
		result = 0.0;
	else:
		result = result * amplitude + offset
		result *= (ease(t, fade_in) if fade_in > 0.0001 else 1.0) * (ease(1.0 - t, fade_out) if fade_out > 0.0001 else 1.0)
	return result;
