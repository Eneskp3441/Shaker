@tool
class_name ShakerTypeCurve3D
extends ShakerTypeBase3D

@export var curve_x: Curve:
	set = set_curve_x,
	get = get_curve_x

@export var curve_y: Curve:
	set = set_curve_y,
	get = get_curve_y

@export var curve_z: Curve:
	set = set_curve_z,
	get = get_curve_z

@export var loop: bool = true:
	set = set_loop,
	get = get_loop

func _curve_changed() -> void:
	_on_property_changed("curve_")

func get_value(t: float) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	if loop && t > 1.0:
		t = fmod(t, 1.0)
	if curve_x:
		result.x = curve_x.sample(t)
	if curve_y:
		result.y = curve_y.sample(t)
	if curve_z:
		result.z = curve_z.sample(t)
		
	return _calc_value(t, result)

func set_curve_x(value: Curve) -> void:
	if curve_x:
		curve_x.changed.disconnect(_curve_changed)
	curve_x = value
	if curve_x:
		curve_x.changed.connect(_curve_changed)
	else:
		_curve_changed()

func get_curve_x() -> Curve:
	return curve_x

func set_curve_y(value: Curve) -> void:
	if curve_y:
		curve_y.changed.disconnect(_curve_changed)
	curve_y = value
	if curve_y:
		curve_y.changed.connect(_curve_changed)
	else:
		_curve_changed()

func get_curve_y() -> Curve:
	return curve_y

func set_curve_z(value: Curve) -> void:
	if curve_z:
		curve_z.changed.disconnect(_curve_changed)
	curve_z = value
	if curve_z:
		curve_z.changed.connect(_curve_changed)
	else:
		_curve_changed()

func get_curve_z() -> Curve:
	return curve_z

func set_loop(value: bool) -> void:
	loop = value
	_on_property_changed("loop")

func get_loop() -> bool:
	return loop
