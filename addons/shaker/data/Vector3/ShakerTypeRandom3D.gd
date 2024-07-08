@tool
class_name ShakerTypeRandom3D
extends ShakerTypeBase3D

## The seed for the random number generator.
@export var seed: int = 0:
	set = set_seed

## The random number generator instance.
var _generator: RandomNumberGenerator = RandomNumberGenerator.new()

## Initializes the shake type with the given seed.
func _init() -> void:
	set_seed(seed)

## Calculates a random value for each axis at time t.
func get_value(t: float) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	result.x = _generator.randf_range(-1.0, 1.0)
	result.y = _generator.randf_range(-1.0, 1.0)
	result.z = _generator.randf_range(-1.0, 1.0)
	return _calc_value(t, result)

## Sets the seed for the random number generator.
func set_seed(value: int) -> void:
	seed = value
	_generator.seed = seed
	_on_property_changed("seed")

## Gets the current seed of the random number generator.
func get_seed() -> int:
	return seed
