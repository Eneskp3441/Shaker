@tool
class_name ShakerTypeBrownianShake3D
extends ShakerTypeBase3D

@export var roughness: Vector3 = Vector3.ONE * 1.0:
	set = set_roughness,
	get = get_roughness

@export var persistence: Vector3 = Vector3.ONE * 0.5:
	set = set_persistence,
	get = get_persistence

var _generator: RandomNumberGenerator = RandomNumberGenerator.new()
var _last_pos: Vector3 = Vector3.ZERO

func _init() -> void:
	property_changed.connect(_property_changed)

func get_value(t: float) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	result.x = (_last_pos.x + _generator.randf_range(-roughness.x, roughness.x))
	result.y = (_last_pos.y + _generator.randf_range(-roughness.y, roughness.y))
	result.z = (_last_pos.z + _generator.randf_range(-roughness.z, roughness.z))
	result = _calc_value(t, result)
	
	_last_pos.x = lerpf(_last_pos.x, result.x, 1.0 - persistence.x)
	_last_pos.y = lerpf(_last_pos.y, result.y, 1.0 - persistence.y)
	_last_pos.z = lerpf(_last_pos.z, result.z, 1.0 - persistence.z)
	return _last_pos

func _property_changed(name: StringName) -> void:
	_last_pos = Vector3.ZERO

func set_roughness(value: Vector3) -> void:
	roughness = value
	_on_property_changed("roughness")

func get_roughness() -> Vector3:
	return roughness

func set_persistence(value: Vector3) -> void:
	persistence = value.clamp(Vector3.ZERO, Vector3.ONE)
	_on_property_changed("persistence")

func get_persistence() -> Vector3:
	return persistence
