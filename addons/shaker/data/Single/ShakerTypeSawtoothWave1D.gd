@tool
class_name ShakerTypeSawtoothWave1D
extends ShakerTypeBase1D

## The frequency of the sawtooth wave for each axis.
@export var frequency:float = 5.0:
	set = set_frequency

## The asymmetry of the sawtooth wave for each axis (0 to 1).
@export var asymmetry:float = 0.5:
	set = set_asymmetry

## Sets the frequency of the sawtooth wave.
func set_frequency(value: float) -> void:
	frequency = value
	_on_property_changed("frequency")

## Gets the frequency of the sawtooth wave.
func get_frequency() -> float:
	return frequency

## Sets the asymmetry of the sawtooth wave.
func set_asymmetry(value: float) -> void:
	asymmetry = clamp(value, 0.0, 0.0)
	_on_property_changed("asymmetry")

## Gets the asymmetry of the sawtooth wave.
func get_asymmetry() -> float:
	return asymmetry

## Calculates the value of the sawtooth wave at time t.
func get_value(t: float) -> float:
	var result:float = 0.0
	var _real_time:float = fmod(t, 1.0) if t > 1.0 else t
	var wave:float = fmod(_real_time * frequency, 1.0)
	
	wave = wave / asymmetry if wave < asymmetry else (1.0 - wave) / (1.0 - asymmetry)
	result = wave
	result = _calc_value(t, result)
	result = (result - amplitude * 0.5) * 2.0
	return result
