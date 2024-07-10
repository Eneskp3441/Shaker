@icon("res://addons/shaker/assets/ShakerType.svg")
@tool
class_name ShakerTypeBase
extends Resource

# Enumerations for blending modes and graph axes
enum BlendingModes {
	Add,
	Override,
	Multiply,
	Subtract,
	Average,
	Max,
	Min
}

# Shake Properties
@export_group("Shake Properties")
@export var BlendingMode: BlendingModes = BlendingModes.Add:
	set = set_blending_mode,
	get = get_blending_mode

@export_exp_easing var fade_in: float = 0.0:
	set = set_fade_in,
	get = get_fade_in

@export_exp_easing("attenuation") var fade_out: float = 0.0:
	set = set_fade_out,
	get = get_fade_out

@export_range(0.0, 1.0) var start_percent: float = 0.0:
	set = set_start_percent,
	get = get_start_percent

@export_range(0.0, 1.0) var end_percent: float = 1.0:
	set = set_end_percent,
	get = get_end_percent

# Live Shake Graph
@export_group("Live Shake Graph")
@export var _temp_graph: bool = false

@export_range(16, 96) var bake_internal: int = 64:
	set = set_bake_internal,
	get = get_bake_internal

var duration = 0.0:
	set = set_duration,
	get = get_duration

func _init(blending_mode:BlendingModes=BlendingModes.Add, fade_in:float=self.fade_in, fade_out:float=self.fade_out, start_percent:float=self.start_percent, end_percent:float=self.end_percent) -> void:
	self.BlendingMode = blending_mode
	self.fade_in = fade_in
	self.fade_out = fade_out
	self.start_percent = start_percent
	self.end_percent = end_percent
	
# Signals
signal property_changed(name: StringName)

# Custom setter and getter functions
func set_blending_mode(value: BlendingModes) -> void:
	BlendingMode = value
	_on_property_changed("BlendingMode")

func get_blending_mode() -> BlendingModes:
	return BlendingMode

func set_fade_in(value: float) -> void:
	fade_in = value
	_on_property_changed("fade_in")

func get_fade_in() -> float:
	return fade_in

func set_fade_out(value: float) -> void:
	fade_out = value
	_on_property_changed("fade_out")

func get_fade_out() -> float:
	return fade_out

func set_start_percent(value: float) -> void:
	start_percent = min(value, end_percent)
	_on_property_changed("start_percent")

func get_start_percent() -> float:
	return start_percent

func set_end_percent(value: float) -> void:
	end_percent = max(value, start_percent)
	_on_property_changed("end_percent")

func get_end_percent() -> float:
	return end_percent

func set_bake_internal(value: int) -> void:
	bake_internal = clamp(value, 16, 96)
	_on_property_changed("bake_internal")

func get_bake_internal() -> int:
	return bake_internal

func set_duration(value: float = 0.0) -> void:
	duration = value

func get_duration() -> float:
	return duration

# Handle property changes
func _on_property_changed(property_name: StringName) -> void:
	property_changed.emit(property_name)
