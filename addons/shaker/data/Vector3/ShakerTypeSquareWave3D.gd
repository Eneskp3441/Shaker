@tool
class_name ShakerTypeSquareWave3D
extends ShakerTypeBase3D

## The frequency of the square wave for each axis.
@export var frequency: Vector3 = Vector3.ONE * 5.0:
	set = set_frequency

## The duty cycle of the square wave for each axis (0 to 1).
@export var duty_cycle: Vector3 = Vector3.ONE * 0.5:
	set = set_duty_cycle

## Sets the frequency of the square wave.
func set_frequency(value: Vector3) -> void:
	frequency = value
	_on_property_changed("frequency")

## Gets the frequency of the square wave.
func get_frequency() -> Vector3:
	return frequency

## Sets the duty cycle of the square wave.
func set_duty_cycle(value: Vector3) -> void:
	duty_cycle = value.clamp(Vector3.ZERO, Vector3.ONE)
	_on_property_changed("duty_cycle")

## Gets the duty cycle of the square wave.
func get_duty_cycle() -> Vector3:
	return duty_cycle

## Calculates the value of the square wave at time t.
func get_value(t: float) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	result.x = 1.0 if fmod(t * frequency.x, 1.0) < duty_cycle.x else -1.0
	result.y = 1.0 if fmod(t * frequency.y, 1.0) < duty_cycle.y else -1.0
	result.z = 1.0 if fmod(t * frequency.z, 1.0) < duty_cycle.z else -1.0
	return _calc_value(t, result)
