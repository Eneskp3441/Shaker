@tool
class_name ShakerTypeBrownianShake1D
extends ShakerTypeBase1D

@export var roughness:float = 1.0:
	set = set_roughness,
	get = get_roughness

@export var persistence:float = 0.5:
	set = set_persistence,
	get = get_persistence

var _generator: RandomNumberGenerator = RandomNumberGenerator.new()
var _last_pos:float = 0.0

func _init() -> void:
	property_changed.connect(_property_changed)

func get_value(t: float) -> float:
	var result:float = 0.0
	result = (_last_pos + _generator.randf_range(-roughness, roughness))
	result = _calc_value(t, result)
	
	_last_pos = lerpf(_last_pos, result, 1.0 - persistence)
	return _last_pos

func _property_changed(name: StringName) -> void:
	_last_pos = 0.0

func set_roughness(value: float) -> void:
	roughness = value
	_on_property_changed("roughness")

func get_roughness() -> float:
	return roughness

func set_persistence(value: float) -> void:
	persistence = clamp(persistence,0, 1)
	_on_property_changed("persistence")

func get_persistence() -> float:
	return persistence
