@tool
class_name ShakerTypeSawtoothWave2D
extends ShakerTypeBase2D

## The frequency of the sawtooth wave for each axis.
@export var frequency: Vector2 = Vector2.ONE * 5.0:
	set = set_frequency

## The asymmetry of the sawtooth wave for each axis (0 to 1).
@export var asymmetry: Vector2 = Vector2.ONE * 0.5:
	set = set_asymmetry

## Sets the frequency of the sawtooth wave.
func set_frequency(value: Vector2) -> void:
	frequency = value
	_on_property_changed("frequency")

## Gets the frequency of the sawtooth wave.
func get_frequency() -> Vector2:
	return frequency

## Sets the asymmetry of the sawtooth wave.
func set_asymmetry(value: Vector2) -> void:
	asymmetry = value.clamp(Vector2.ZERO, Vector2.ONE)
	_on_property_changed("asymmetry")

## Gets the asymmetry of the sawtooth wave.
func get_asymmetry() -> Vector2:
	return asymmetry

## Calculates the value of the sawtooth wave at time t.
func get_value(t: float) -> Vector2:
	var result: Vector2 = Vector2.ZERO
	var _real_time: float = fmod(t, 1.0) if t > 1.0 else t
	var wave: Vector2 = (_real_time * frequency).posmod(1.0)
	
	wave.x = wave.x / asymmetry.x if wave.x < asymmetry.x else (1.0 - wave.x) / (1.0 - asymmetry.x)
	wave.y = wave.y / asymmetry.y if wave.y < asymmetry.y else (1.0 - wave.y) / (1.0 - asymmetry.y)
	result = wave
	result = _calc_value(t, result)
	result = (result - amplitude * 0.5) * 2.0
	return result
