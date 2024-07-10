@tool
@icon("res://addons/shaker/assets/ShakerPreset3D.svg")
class_name ShakerPreset3D
extends ShakerPresetBase

# Shake type arrays for each category
@export var PositionShake: Array[ShakerTypeBase3D]:
	set = set_position_shake,
	get = get_position_shake

@export var RotationShake: Array[ShakerTypeBase3D]:
	set = set_rotation_shake,
	get = get_rotation_shake

@export var ScaleShake: Array[ShakerTypeBase3D]:
	set = set_scale_shake,
	get = get_scale_shake

# Custom setter and getter functions
func set_position_shake(value: Array[ShakerTypeBase3D]) -> void:
	for _shake_type in _array_difference(PositionShake, value):
		if _shake_type != null:
			_shake_type.property_changed.connect(_on_property_changed)
			_shake_type.property_changed.connect(_change_graph_category.bind(0))
	PositionShake = value
	if Graph != null:
		Graph.select_category(0)
		Graph._on_fit_button_clicked()
	_on_property_changed("PositionShake")

func get_position_shake() -> Array[ShakerTypeBase3D]:
	return PositionShake

func set_rotation_shake(value: Array[ShakerTypeBase3D]) -> void:
	for _shake_type in _array_difference(RotationShake, value):
		if _shake_type != null:
			_shake_type.property_changed.connect(_on_property_changed)
			_shake_type.property_changed.connect(_change_graph_category.bind(1))
	RotationShake = value
	if Graph != null:
		Graph.select_category(1)
		Graph._on_fit_button_clicked()
	_on_property_changed("RotationShake")

func get_rotation_shake() -> Array[ShakerTypeBase3D]:
	return RotationShake

func set_scale_shake(value: Array[ShakerTypeBase3D]) -> void:
	for _shake_type in _array_difference(ScaleShake, value):
		if _shake_type != null:
			_shake_type.property_changed.connect(_on_property_changed)
			_shake_type.property_changed.connect(_change_graph_category.bind(2))
	ScaleShake = value
	if Graph != null:
		Graph.select_category(2)
		Graph._on_fit_button_clicked()
	_on_property_changed("ScaleShake")

func get_scale_shake() -> Array[ShakerTypeBase3D]:
	return ScaleShake

# Get the shake value for a given time and category
func get_value(t: float, _category: Categories = Categories.POSITION) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	var selected_category: Array[ShakerTypeBase3D] = [PositionShake, RotationShake, ScaleShake][_category]
	for shake_type in selected_category:
		if shake_type != null:
			shake_type.duration = component_duration
			var _shake_result: Vector3 = shake_type.get_value(t)
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
					result.z = max(result.z, _shake_result.z)
				shake_type.BlendingModes.Min:
					result.x = min(result.x, _shake_result.x)
					result.y = min(result.y, _shake_result.y)
					result.z = min(result.z, _shake_result.z)
				shake_type.BlendingModes.Average:
					result = (result + _shake_result) * 0.5
				shake_type.BlendingModes.Override:
					result = _shake_result
	return result

func _change_graph_category(_name:String, _category_index:int) -> void:
	if Graph:
		Graph.category_button.select(_category_index)
		Graph.category_button.item_selected.emit(_category_index)

func get_shakes_by_category(category:Categories) -> Array:
	if category == Categories.POSITION:
		return PositionShake
	elif category == Categories.ROTATION:
		return RotationShake
	elif category == Categories.SCALE:
		return ScaleShake
	return [null]
