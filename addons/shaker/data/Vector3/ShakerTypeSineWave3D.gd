@tool
class_name ShakerTypeSineWave3D
extends ShakerTypeBase3D

@export_group("Sinewave Properties")
@export var frequency: Vector3 = Vector3.ONE:
	set = set_frequency,
	get = get_frequency

@export var phase: Vector3 = Vector3.ONE:
	set = set_phase,
	get = get_phase

func get_value(t: float) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	var _real_time: float = fmod(t, 1.0) if t > 1.0 else t
	result.x = sin(t * frequency.x * TAU + phase.x)
	result.y = sin(t * frequency.y * TAU + phase.y + PI/2)
	result.z = sin(t * frequency.z * TAU + phase.z + PI/4)
	return _calc_value(_real_time, result)

func set_frequency(value: Vector3) -> void:
	frequency = value
	_on_property_changed("frequency")

func get_frequency() -> Vector3:
	return frequency

func set_phase(value: Vector3) -> void:
	phase = value
	_on_property_changed("phase")

func get_phase() -> Vector3:
	return phase
