@tool
@icon("res://addons/shaker/assets/ShakerPreset.svg")
class_name ShakerPresetBase
extends Resource

# Enum for shake categories
enum Categories {
	POSITION,
	ROTATION,
	SCALE
}

# Graph panel reference
var Graph: Panel

# Bake internal setting
@export_range(16, 96) var bake_internal: int = 64:
	set = set_bake_internal,
	get = get_bake_internal

# Follow timeline flag
@export var __follow_timeline: bool = false:
	set = set_follow_timeline,
	get = get_follow_timeline

# Component duration and parent node
var component_duration: float = 0.0
var parent: Node

# Signal for property changes
signal property_changed(name: StringName)

func set_bake_internal(value: int) -> void:
	bake_internal = clamp(value, 16, 96)
	_on_property_changed("bake_internal")

func get_bake_internal() -> int:
	return bake_internal

func set_follow_timeline(value: bool) -> void:
	__follow_timeline = value
	_on_property_changed("__follow_timeline")

func get_follow_timeline() -> bool:
	return __follow_timeline

# Handle property changes
func _on_property_changed(property_name: StringName) -> void:
	property_changed.emit(property_name)

# Calculate the difference between two arrays
func _array_difference(a: Array, b: Array) -> Array:
	return b.filter(func(item): return not a.has(item))
