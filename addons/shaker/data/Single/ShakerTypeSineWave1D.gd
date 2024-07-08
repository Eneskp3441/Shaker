@tool
class_name ShakerTypeSineWave1D
extends ShakerTypeBase1D

@export_group("Sinewave Properties")
@export var frequency:float = 1.0:
	set = set_frequency,
	get = get_frequency

@export var phase:float = 0.0:
	set = set_phase,
	get = get_phase

func get_value(t: float) -> float:
	var result:float = 0.0
	var _real_time: float = fmod(t, 1.0) if t > 1.0 else t
	result = sin(t * frequency * TAU + phase)
	return _calc_value(_real_time, result)

func set_frequency(value: float) -> void:
	frequency = value
	_on_property_changed("frequency")

func get_frequency() -> float:
	return frequency

func set_phase(value: float) -> void:
	phase = value
	_on_property_changed("phase")

func get_phase() -> float:
	return phase
