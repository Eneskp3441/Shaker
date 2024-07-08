@tool
class_name ShakerTypeBrownianShake2D
extends ShakerTypeBase2D

@export var roughness: Vector2 = Vector2.ONE * 1.0:
	set = set_roughness,
	get = get_roughness

@export var persistence: Vector2 = Vector2.ONE * 0.5:
	set = set_persistence,
	get = get_persistence

var _generator: RandomNumberGenerator = RandomNumberGenerator.new()
var _last_pos: Vector2 = Vector2.ZERO

func _init() -> void:
	property_changed.connect(_property_changed)

func get_value(t: float) -> Vector2:
	var result: Vector2 = Vector2.ZERO
	result.x = (_last_pos.x + _generator.randf_range(-roughness.x, roughness.x))
	result.y = (_last_pos.y + _generator.randf_range(-roughness.y, roughness.y))
	result = _calc_value(t, result)
	
	_last_pos.x = lerpf(_last_pos.x, result.x, 1.0 - persistence.x)
	_last_pos.y = lerpf(_last_pos.y, result.y, 1.0 - persistence.y)
	return _last_pos

func _property_changed(name: StringName) -> void:
	_last_pos = Vector2.ZERO

func set_roughness(value: Vector2) -> void:
	roughness = value
	_on_property_changed("roughness")

func get_roughness() -> Vector2:
	return roughness

func set_persistence(value: Vector2) -> void:
	persistence = value.clamp(Vector2(0,0),Vector2(1,1))
	_on_property_changed("persistence")

func get_persistence() -> Vector2:
	return persistence
