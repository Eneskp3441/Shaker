@tool
@icon("res://addons/shaker/assets/Shaker2D.svg")
class_name ShakerComponent2D
extends "res://addons/shaker/src/Vector2/ShakerBase2D.gd"

## Allows you to apply shake effect to any 2D node according to position, rotation, scale

enum ShakeAddMode {
	add,
	override
}

# Custom target flag
@export var custom_target: bool = false:
	set = set_custom_target,
	get = get_custom_target

# Array of target Node2D objects
@export var Targets: Array[Node2D]

# Randomization flag
@export var randomize: bool = false:
	set = set_randomize,
	get = get_randomize

# Playing state
@export var is_playing: bool = false

@export var AutoPlay:bool = false

# Private variables
var _last_position_shake: Array[Vector2] = [Vector2.ZERO]
var _last_scale_shake: Array[Vector2] = [Vector2.ZERO]
var _last_rotation_shake: Array[float] = [0]
var _timer_offset: float = 0.0
var _fading_out: bool = false
var _seed: float = 203445
var _external_shakes:Array[ExternalShake]

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	set_process_input(false)
	set_process_internal(false)
	set_process_shortcut_input(false)
	set_process_unhandled_input(false)
	set_physics_process(false)
	set_physics_process_internal(false)
	add_to_group("ShakerComponent")
	
	if !Engine.is_editor_hint():
		if AutoPlay:
			play_shake()

# Resets the shaker to its initial state
func _reset() -> void:
	_last_position_shake = [Vector2.ZERO]
	_last_scale_shake = [Vector2.ZERO]
	_last_rotation_shake = [0]
	_external_shakes.clear()
	_initalize_prev_positions()
	is_playing = false
	_initialize_timer_offset()
	_fading_out = false
	_initalize_target()

# Initializes previous positions for randomized shaking
func _initalize_prev_positions() -> void:
	_last_position_shake.resize(Targets.size())
	_last_position_shake.fill(Vector2.ZERO)
	
	_last_scale_shake.resize(Targets.size())
	_last_scale_shake.fill(Vector2.ZERO)
	
	_last_rotation_shake.resize(Targets.size())
	_last_rotation_shake.fill(0)

# Called every frame
func _process(delta: float) -> void:
	if is_playing:
		if shakerPreset != null || _external_shakes.size() > 0 || is_receiving_from_emitters():
			if timer <= duration || duration == 0.0:
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
	var _final_duration: float = duration if (duration > 0 && !_fading_out) else 1.0
	
	_ease_in = ease((timer)/_final_duration, fade_in)
	_ease_out = ease(1.0-(max((timer)-_timer_offset, 0.0))/_final_duration, fade_out)
	
	if (!(duration > 0) || _fading_out) && is_playing:
		if _ease_out <= get_process_delta_time():
			force_stop_shake()
	
	var _shake_position: Array[Vector2] = []
	var _shake_rotation: Array[float] = []
	var _shake_scale: Array[Vector2] = []
	
	var _count:int =(Targets.size() if randomize else 1)
	
	_shake_position.resize(_count)
	_shake_position.fill(Vector2.ZERO)
	_shake_rotation.resize(_count)
	_shake_rotation.fill(0)
	_shake_scale.resize(_count)
	_shake_scale.fill(Vector2.ZERO)
	
	for _index in _count:
		var _randomized: float = (_seed * (float(_index+1) / Targets.size())) if randomize else 0.0
		if _last_position_shake.size() != _count: _initalize_prev_positions()
		
		# Shaker Preset
		if shakerPreset != null:
			var _value:float = timer + _randomized
			var _strength:float = intensity * _ease_in * _ease_out
			
			_shake_position[_index] += (shakerPreset.get_value(_value, ShakerPreset2D.Categories.POSITION) * _strength)
			_shake_rotation[_index] += (shakerPreset.get_value(_value, ShakerPreset2D.Categories.ROTATION) * _strength * (PI/2.0))
			_shake_scale[_index] += (shakerPreset.get_value(_value, ShakerPreset2D.Categories.SCALE) * _strength)
		
		# External Shake Addition
		for external_shake:ExternalShake in _external_shakes:
			var _real_time:float = min(timer-external_shake.start_time, external_shake.duration)
			_ease_in = ease(_real_time/external_shake.duration, external_shake.fade_in)
			_ease_out = ease(1.0-(_real_time/external_shake.duration), external_shake.fade_out)
			var _value:float = (_real_time*external_shake.speed) + _randomized
			var _strength:float = external_shake.intensity * intensity * _ease_in * _ease_out
			var _mode_value:Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
			match external_shake.mode:
				ShakeAddMode.add:
					_mode_value = [_shake_position[_index], Vector2(_shake_rotation[_index], 0.0), _shake_scale[_index] ]
			_shake_position[_index] = _mode_value[0] + (external_shake.preset.get_value(_value, ShakerPreset2D.Categories.POSITION) * _strength)
			_shake_rotation[_index] = _mode_value[1].x +(external_shake.preset.get_value(_value, ShakerPreset2D.Categories.ROTATION).x * _strength * (PI/2.0))
			_shake_scale[_index] = _mode_value[2] + (external_shake.preset.get_value(_value, ShakerPreset2D.Categories.SCALE) * _strength)
			
			if _real_time >= external_shake.duration:
				_external_shakes.erase(external_shake)
		
		# Shake Emitter
		for _child in get_children():
			if _child is ShakerReceiver2D:
				_shake_position[_index] += _child.position_offset
				_shake_rotation[_index] += _child.rotation_offset
				_shake_scale[_index] += _child.scale_offset
		
	for index: int in Targets.size():
		var target: Node2D = Targets[index]
		if !is_instance_valid(target):
			Targets.remove_at(index)
			index-=1
			if Targets.size() <= 0:
				shake_finished.emit()
				break
		var _i:int = fmod(index, _shake_position.size())
		target.position += -_last_position_shake[_i] + _shake_position[_i]
		target.rotation += -_last_rotation_shake[_i] + _shake_rotation[_i]
		target.scale += -_last_scale_shake[_i] + _shake_scale[_i]
		
	_last_position_shake = _shake_position
	_last_rotation_shake = _shake_rotation
	_last_scale_shake = _shake_scale

# Stops the shake effect with a fade-out
func stop_shake() -> void:
	if !_fading_out:
		_timer_offset = timer
		_fading_out = true
		shake_fading_out.emit()

# Immediately stops the shake effect
func force_stop_shake() -> void:
	if is_playing || _fading_out:
		set_progress(0.0)
		_reset()
		shake_finished.emit()

# Starts the shake effect
func play_shake() -> void:
	_initalize_target()
	randomize_shake()
	is_playing = !is_playing if Engine.is_editor_hint() else true
	_fading_out = false
	_initialize_timer_offset()
	shake_started.emit()

func randomize_shake() -> void:
	_seed = randf_range(10000, 99999)

func _initalize_target() -> void:
	if !custom_target:
		Targets.clear()
		if get_parent() is Node2D:
			Targets.append(get_parent())

# Placeholder for shake function
func shake(shaker_preset:ShakerPreset2D, _mode:ShakeAddMode=ShakeAddMode.add, duration:float=1.0, speed:float=1.0, intensity:float=1.0, fade_in:float=.25, fade_out:float=.25) -> void:
	var external_shake:ExternalShake = ExternalShake.new()
	external_shake.preset = shaker_preset
	external_shake.duration = duration
	external_shake.speed = speed
	external_shake.intensity = intensity
	external_shake.start_time = timer
	external_shake.fade_in = fade_in
	external_shake.fade_out = fade_out
	external_shake.mode = _mode
	_external_shakes.append(external_shake)
	if Targets.is_empty():
		_initalize_target()
	is_playing = true

# Validates property visibility
func _validate_property(property: Dictionary) -> void:
	if property.name == "Targets" || property.name == "randomize":
		if !custom_target:
			property.usage = PROPERTY_USAGE_NONE
	if property.name == "fade_time":
		if duration > 0:
			property.usage = PROPERTY_USAGE_NONE

# Get configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	if !custom_target:
		if not get_parent() is Node2D:
			return ["Parent must be Node2D"]
		
	return []

# Sets the shake progress
func set_progress(value: float) -> void:
	timer = value
	_progress_shake()



# Custom setter and getter functions for @export variables
func set_custom_target(value: bool) -> void:
	custom_target = value
	notify_property_list_changed()

func get_custom_target() -> bool:
	return custom_target

func set_randomize(value: bool) -> void:
	if custom_target && Targets.size() > 1:
		for index: int in Targets.size():
			var target: Node2D = Targets[index]
			var i = fmod(index, _last_position_shake.size())
			target.position += -_last_position_shake[i]
			target.rotation += -_last_rotation_shake[i]
			target.scale += -_last_scale_shake[i]
		_last_position_shake.fill(_last_position_shake[0])
		_last_rotation_shake.fill(_last_rotation_shake[0])
		_last_scale_shake.fill(_last_scale_shake[0])
	randomize = value
	randomize_shake()

func get_randomize() -> bool:
	return randomize

class ExternalShake:
	var preset:ShakerPreset2D
	var duration:float = 1.0
	var speed:float = 1.0
	var intensity:float = 1.0
	var start_time:float = 0.0
	var fade_in:float = 0.25
	var fade_out:float = 0.25
	var mode:ShakeAddMode=ShakeAddMode.add

func _initialize_timer_offset() -> void:
	if !(duration > 0): _timer_offset = 0x80000
	else: _timer_offset = 0.0

func is_receiving_from_emitters() -> bool:
	for _child in get_children():
			if _child is ShakerReceiver2D:
				return _child.is_playing()
	return false
