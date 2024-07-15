@icon("res://addons/shaker/assets/ShakerEmitter2D.svg")
@tool
class_name ShakerEmitter2D
extends "res://addons/shaker/src/Vector2/ShakerBase2D.gd"

## It emits shake values and is received by ShakeEmitter2D.

# Exported variables
@export var emit: bool:
	set = set_emit,
	get = get_emit

@export var max_distance: float = 0.0:
	set = set_max_distance,
	get = get_max_distance

@export_exp_easing("attenuation") var distance_attenuation: float = 0.5:
	set = set_distance_attenuation,
	get = get_distance_attenuation

# Private variables
var emitting: bool = false
var _timer_offset: float = 0.0
var _fading_out: bool = false
var shake_offset_position: Vector2 = Vector2.ZERO
var shake_offset_rotation:float = 0.0
var shake_offset_scale: Vector2 = Vector2.ZERO
var area2d: Area2D
var collision:CollisionShape2D

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	add_to_group("ShakerEmitter")
	
	for child in get_children():
		if child is Area2D:
			area2d = child
	
	if not area2d:
		_create_Area2D()
	
	set_emit(emit)

# Creates an Area2D child node if one doesn't exist
func _create_Area2D() -> void:
	area2d = Area2D.new()
	collision = CollisionShape2D.new()
	add_child(area2d)
	area2d.add_child(collision)
	area2d.set_owner(get_tree().edited_scene_root)
	collision.set_owner(get_tree().edited_scene_root)
	area2d.name = "Area2D"
	collision.name = "CollisionShape2D"
	
	area2d.collision_layer = 1 << 9
	area2d.collision_mask = 0

# Called every frame
func _process(delta: float) -> void:
	if emitting:
		if shakerPreset != null:
			if timer <= duration or duration == 0.0:
				_progress_shake()
				timer += delta * shake_speed
			else:
				force_stop_shake()
		else:
			if timer > 0:
				force_stop_shake()

# Progresses the shake effect
func _progress_shake() -> void:
	var _ease_in: float = 1.0
	var _ease_out: float = 1.0
	var _final_duration: float = duration if (duration > 0 and not _fading_out) else 1.0
	
	_ease_in = ease(timer/_final_duration, fade_in)
	_ease_out = ease(1.0 - (max((timer - _timer_offset), 0.0))/_final_duration, fade_out)
	
	if not (duration > 0) or _fading_out:
		if _ease_out <= get_process_delta_time():
			force_stop_shake()
	
	var _shake_position: Vector2 = Vector2.ZERO
	var _shake_rotation:float = 0.0
	var _shake_scale: Vector2 = Vector2.ZERO
	
	if shakerPreset != null:
		var _value: float = timer
		var _strength: float = intensity * _ease_in * _ease_out
		
		_shake_position += (shakerPreset.get_value(_value, ShakerPreset2D.Categories.POSITION) * _strength)
		_shake_rotation += (shakerPreset.get_value(_value, ShakerPreset2D.Categories.ROTATION) * _strength * (PI/2.0))
		_shake_scale += (shakerPreset.get_value(_value, ShakerPreset2D.Categories.SCALE) * _strength)
	
	shake_offset_position = _shake_position
	shake_offset_rotation = _shake_rotation
	shake_offset_scale = _shake_scale

# Starts the shake effect
func play_shake() -> void:
	if shakerPreset != null:
		emitting = true
		_fading_out = false
		_initialize_timer_offset()
		shake_started.emit()

func _initialize_timer_offset() -> void:
	if !(duration > 0): _timer_offset = 0x80000
	else: _timer_offset = 0.0

# Stops the shake effect with a fade-out
func stop_shake() -> void:
	if not _fading_out:
		_timer_offset = timer
		_fading_out = true
		shake_fading_out.emit()

# Immediately stops the shake effect
func force_stop_shake() -> void:
	if emitting:
		if emit: emit = false
		_fading_out = false
		emitting = false
		set_progress(0.0)
		shake_finished.emit()

# Returns configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	if not get_children().any(func(child): return child is Area2D):
		return ["First child must be Area2D"]
	return []

# Sets the shake progress
func set_progress(value: float) -> void:
	timer = value
	_progress_shake()

# Setter for emit property
func set_emit(value: bool) -> void:
	emit = value
	if value:
		play_shake()
	elif timer > 0:
		force_stop_shake()

# Getter for emit property
func get_emit() -> bool:
	return emit

# Setter for max_distance property
func set_max_distance(value: float) -> void:
	max_distance = value
	notify_property_list_changed()

# Getter for max_distance property
func get_max_distance() -> float:
	return max_distance

# Setter for distance_attenuation property
func set_distance_attenuation(value: float) -> void:
	distance_attenuation = value

# Getter for distance_attenuation property
func get_distance_attenuation() -> float:
	return distance_attenuation

# Validates properties
func _validate_property(property: Dictionary) -> void:
	if property.name == "distance_attenuation":
		if not (max_distance > 0):
			property.usage = PROPERTY_USAGE_NONE
