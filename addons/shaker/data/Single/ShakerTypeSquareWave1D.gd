@tool
class_name ShakerTypeSquareWave1D
extends ShakerTypeBase1D

## The frequency of the square wave for each axis.
@export var frequency:float = 5.0:
	set = set_frequency

## The duty cycle of the square wave for each axis (0 to 1).
@export var duty_cycle:float = 0.5:
	set = set_duty_cycle

## Sets the frequency of the square wave.
func set_frequency(value:float) -> void:
	frequency = value
	_on_property_changed("frequency")

## Gets the frequency of the square wave.
func get_frequency() -> float:
	return frequency

## Sets the duty cycle of the square wave.
func set_duty_cycle(value:float) -> void:
	duty_cycle = clamp(value, 0.0, 0.0)
	_on_property_changed("duty_cycle")

## Gets the duty cycle of the square wave.
func get_duty_cycle() -> float:
	return duty_cycle

## Calculates the value of the square wave at time t.
func get_value(t: float) -> float:
	var result:float = 0.0
	result = 1.0 if fmod(t * frequency, 1.0) < duty_cycle else -1.0
	return _calc_value(t, result)
