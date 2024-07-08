@tool
class_name ShakerTypeSawtoothWave3D
extends ShakerTypeBase3D

## The frequency of the sawtooth wave for each axis.
@export var frequency: Vector3 = Vector3.ONE * 5.0:
	set = set_frequency

## The asymmetry of the sawtooth wave for each axis (0 to 1).
@export var asymmetry: Vector3 = Vector3.ONE * 0.5:
	set = set_asymmetry

## Sets the frequency of the sawtooth wave.
func set_frequency(value: Vector3) -> void:
	frequency = value
	_on_property_changed("frequency")

## Gets the frequency of the sawtooth wave.
func get_frequency() -> Vector3:
	return frequency

## Sets the asymmetry of the sawtooth wave.
func set_asymmetry(value: Vector3) -> void:
	asymmetry = value.clamp(Vector3.ZERO, Vector3.ONE)
	_on_property_changed("asymmetry")

## Gets the asymmetry of the sawtooth wave.
func get_asymmetry() -> Vector3:
	return asymmetry

## Calculates the value of the sawtooth wave at time t.
func get_value(t: float) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	var _real_time: float = fmod(t, 1.0) if t > 1.0 else t
	var wave: Vector3 = (_real_time * frequency).posmod(1.0)
	
	wave.x = wave.x / asymmetry.x if wave.x < asymmetry.x else (1.0 - wave.x) / (1.0 - asymmetry.x)
	wave.y = wave.y / asymmetry.y if wave.y < asymmetry.y else (1.0 - wave.y) / (1.0 - asymmetry.y)
	wave.z = wave.z / asymmetry.z if wave.z < asymmetry.z else (1.0 - wave.z) / (1.0 - asymmetry.z)
	result = wave
	result = _calc_value(t, result)
	result = (result - amplitude * 0.5) * 2.0
	return result
