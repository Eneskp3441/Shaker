@tool
extends Node2D

# Shake intensity
@export_range(0.0, 1.0, 0.001, "or_greater") var intensity: float = 1.0:
	set = set_intensity,
	get = get_intensity

# Shake duration
@export var duration: float = 0.00:
	set = set_duration,
	get = get_duration

# Shake speed
@export_range(0.0, 1.0, 0.001, "or_greater") var shake_speed: float = 1.0:
	set = set_shake_speed,
	get = get_shake_speed

# Fade-in easing
@export_exp_easing var fade_in: float = 0.25:
	set = set_fade_in,
	get = get_fade_in

# Fade-out easing
@export_exp_easing("attenuation") var fade_out: float = 0.25:
	set = set_fade_out,
	get = get_fade_out

# Shaker preset
@export var shakerPreset:ShakerPreset2D:
	set = set_shaker_preset,
	get = get_shaker_preset

# Timer for shake progress
var timer: float = 0.0:
	set = _on_timeline_progress

# SIGNALS
signal timeline_progress(progress: float)
signal shake_started
signal shake_finished
signal shake_fading_out

func set_intensity(value: float) -> void:
	intensity = max(value, 0.0)

func get_intensity() -> float:
	return intensity

func set_duration(value: float) -> void:
	duration = max(value, 0.0)
	if shakerPreset != null:
		shakerPreset.component_duration = duration
	notify_property_list_changed()

func get_duration() -> float:
	return duration

func set_shake_speed(value: float) -> void:
	shake_speed = max(value, 0.001)
	notify_property_list_changed()

func get_shake_speed() -> float:
	return shake_speed

func set_fade_in(value: float) -> void:
	fade_in = value

func get_fade_in() -> float:
	return fade_in

func set_fade_out(value: float) -> void:
	fade_out = value

func get_fade_out() -> float:
	return fade_out

func set_shaker_preset(value: ShakerPreset2D) -> void:
	shakerPreset = value
	if shakerPreset != null:
		shakerPreset.parent = self
		shakerPreset.component_duration = duration

func get_shaker_preset() -> ShakerPreset2D:
	return shakerPreset
	
# Handles timeline progress
func _on_timeline_progress(value: float) -> void:
	timer = value
	timeline_progress.emit(timer)
