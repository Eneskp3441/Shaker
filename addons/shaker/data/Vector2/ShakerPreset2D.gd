@tool
@icon("res://addons/shaker/assets/ShakerPreset2D.svg")
class_name ShakerPreset2D
extends ShakerPresetBase


# Shake type arrays for each category
@export var PositionShake: Array[ShakerTypeBase2D]:
	set = set_position_shake,
	get = get_position_shake

@export var RotationShake: Array[ShakerTypeBase1D]:
	set = set_rotation_shake,
	get = get_rotation_shake

@export var ScaleShake: Array[ShakerTypeBase2D]:
	set = set_scale_shake,
	get = get_scale_shake

# Custom setter and getter functions
func set_position_shake(value: Array[ShakerTypeBase2D]) -> void:
	for _shake_type in _array_difference(PositionShake, value):
		if _shake_type != null:
			_shake_type.property_changed.connect(_on_property_changed)
	PositionShake = value
	_on_property_changed("PositionShake")
	if Graph != null:
		Graph._on_fit_button_clicked()

func get_position_shake() -> Array[ShakerTypeBase2D]:
	return PositionShake

func set_rotation_shake(value: Array[ShakerTypeBase1D]) -> void:
	for _shake_type in _array_difference(RotationShake, value):
		if _shake_type != null:
			_shake_type.property_changed.connect(_on_property_changed)
	RotationShake = value
	_on_property_changed("RotationShake")
	if Graph != null:
		Graph._on_fit_button_clicked()

func get_rotation_shake() -> Array[ShakerTypeBase1D]:
	return RotationShake

func get_shakes_by_category(category:Categories) -> Array:
	if category == Categories.POSITION:
		return PositionShake
	elif category == Categories.ROTATION:
		return RotationShake
	elif category == Categories.SCALE:
		return ScaleShake
	return [null]

func set_scale_shake(value: Array[ShakerTypeBase2D]) -> void:
	for _shake_type in _array_difference(ScaleShake, value):
		if _shake_type != null:
			_shake_type.property_changed.connect(_on_property_changed)
	ScaleShake = value
	_on_property_changed("ScaleShake")
	if Graph != null:
		Graph._on_fit_button_clicked()

func get_scale_shake() -> Array[ShakerTypeBase2D]:
	return ScaleShake

# Get the shake value for a given time and category
func get_value(t: float, _category: Categories = Categories.POSITION):
	var result
	if _category == Categories.ROTATION:
		result = 0.0
	else:
		result = Vector2.ZERO
	for shake_type in [PositionShake, RotationShake, ScaleShake][_category]:
		if shake_type != null:
			shake_type.duration = component_duration
			var _shake_result = shake_type.get_value(t)
			match shake_type.BlendingMode:
				shake_type.BlendingModes.Add:
					result += _shake_result
				shake_type.BlendingModes.Multiply:
					result *= _shake_result
				shake_type.BlendingModes.Subtract:
					result -= _shake_result
				shake_type.BlendingModes.Max:
					result.x = max(result.x, _shake_result.x)
					result.y = max(result.y, _shake_result.y)
				shake_type.BlendingModes.Min:
					result.x = min(result.x, _shake_result.x)
					result.y = min(result.y, _shake_result.y)
				shake_type.BlendingModes.Average:
					result = (result + _shake_result) * 0.5
				shake_type.BlendingModes.Override:
					result = _shake_result
	return result
