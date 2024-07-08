@tool
class_name ShakerTypeCurve1D
extends ShakerTypeBase1D

@export var curve: Curve:
	set = set_curve,
	get = get_curve

@export var loop: bool = true:
	set = set_loop,
	get = get_loop

func _curve_changed() -> void:
	_on_property_changed("curve")

func get_value(t: float) -> float:
	var result: float = 0.0
	if loop && t > 1.0:
		t = fmod(t, 1.0)
	if curve:
		result = curve.sample(t)
		
	return _calc_value(t, result)

func set_curve(value: Curve) -> void:
	if curve:
		curve.changed.disconnect(_curve_changed)
	curve = value
	if curve:
		curve.changed.connect(_curve_changed)
	else:
		_curve_changed()
func get_curve() -> Curve:
	return curve

func set_loop(value: bool) -> void:
	loop = value
	_on_property_changed("loop")

func get_loop() -> bool:
	return loop
