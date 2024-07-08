@tool
class_name ShakerTypeSineWave2D
extends ShakerTypeBase2D

@export_group("Sinewave Properties")
@export var frequency: Vector2 = Vector2.ONE:
	set = set_frequency,
	get = get_frequency

@export var phase: Vector2 = Vector2.ONE:
	set = set_phase,
	get = get_phase

func get_value(t: float) -> Vector2:
	var result: Vector2 = Vector2.ZERO
	var _real_time: float = fmod(t, 1.0) if t > 1.0 else t
	result.x = sin(t * frequency.x * TAU + phase.x)
	result.y = sin(t * frequency.y * TAU + phase.y + PI/2)
	return _calc_value(_real_time, result)

func set_frequency(value: Vector2) -> void:
	frequency = value
	_on_property_changed("frequency")

func get_frequency() -> Vector2:
	return frequency

func set_phase(value: Vector2) -> void:
	phase = value
	_on_property_changed("phase")

func get_phase() -> Vector2:
	return phase
