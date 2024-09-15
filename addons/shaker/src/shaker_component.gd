@tool
@icon("res://addons/shaker/assets/Shaker.svg")
class_name ShakerComponent
extends Node

# Allows you to apply a shake effect to any variable of a node of any type

# Custom target flag
@export var custom_target: bool = false:
	set = set_custom_target,
	get = get_custom_target

# Array of target Node objects
@export var Targets: Array[Node]

# Randomization flag
@export var randomize: bool = false:
	set = set_randomize,
	get = get_randomize

@export var AutoPlay:bool = false

# Playing state
@export var play:bool = false:
	set(value):
		play = value
		if value:
			play_shake()
		elif timer > 0:
			force_stop_shake()

var is_playing: bool = false

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
@export var shakerProperty:Array[ShakerProperty]:
	set = set_shaker_property,
	get = get_shaker_property

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
	
# Handles timeline progress
func _on_timeline_progress(value: float) -> void:
	timer = value
	timeline_progress.emit(timer)

# Private variables
var _timer_offset: float = 0.0
var _fading_out: bool = false
var _seed: float = 203445
var _last_values:Array[Dictionary]

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
	_last_values = []
	is_playing = false
	_initialize_timer_offset()
	_fading_out = false
	_initalize_target()

# Called every frame
func _process(delta: float) -> void:
	if is_playing:
		if shakerProperty != null:
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
	
	_ease_in = ease(timer/_final_duration, fade_in)
	_ease_out = ease(1.0-(max((timer-_timer_offset), 0.0))/_final_duration, fade_out)
	
	# Check all targets
	for i:int in Targets.size():
		var target:Node = Targets[i]
		if !is_instance_valid(target):
				Targets.remove_at(i)
				i -= 1
				if Targets.size() <= 0:
					shake_finished.emit()
					break
	
	if (!(duration > 0) || _fading_out) && is_playing:
		if _ease_out <= get_process_delta_time():
			force_stop_shake()
	var _count:int = Targets.size() # if randomize else 1)
	var _value_temp:Array[Dictionary] = []
	for i in _count:
		_value_temp.append({})
	
	for _index:int in _count:
		var _randomized:float = (_seed * (float(_index+1) / Targets.size())) if randomize else 0.0
		var target:Node = Targets[_index]
		if _index > _last_values.size()-1:
			_last_values.append({})
		
		# Shaker Preset
		for shake:ShakerProperty in shakerProperty:
			if shake:
				if !shake.property_name.is_empty() && shake.shake_type:
					var _value:float = timer + _randomized
					
					var _add_value = (shake.get_value(_value))
					var current_value = target.get(shake.property_name)
					if typeof(current_value) == typeof(current_value):
						if !(_last_values[_index].has(shake.property_name)):
							_last_values[_index][shake.property_name] = {}
							_last_values[_index][shake.property_name]["value"] = _add_value * 0.0
						
						var _prev_temp = (_add_value * 0.0) if !(_value_temp[_index].has(shake.property_name)) else _value_temp[_index][shake.property_name]["value"]
						_value_temp[_index][shake.property_name] = {}
						_value_temp[_index][shake.property_name]["value"] = _prev_temp + _add_value
						_value_temp[_index][shake.property_name]["blend_mode"] = shake.shake_type.BlendingMode
					else:
						push_error("Variable value type is %s but Shake type is %s" % [type_string(current_value), type_string(_add_value)])
	var _strength:float = intensity * _ease_in * _ease_out
	for index:int in Targets.size():
		var target:Node = Targets[index]
		var i:int = fmod(index, _value_temp.size())
		var property = _value_temp[i]
		for property_index:int in property.size():
			var property_name:StringName = property.keys()[property_index]
			if !property_name.is_empty():
				var value = property[property_name]["value"]
				var blend_mode = property[property_name]["blend_mode"]
				var current_value = target.get(property_name)-_last_values[i][property_name]["value"]
				var default_value = current_value
				match blend_mode:
					ShakerTypeBase.BlendingModes.Add:
						current_value += value
					ShakerTypeBase.BlendingModes.Multiply:
						current_value *= value
					ShakerTypeBase.BlendingModes.Subtract:
						current_value -= value
					ShakerTypeBase.BlendingModes.Max:
						if typeof(current_value) == TYPE_VECTOR2 || typeof(current_value) == TYPE_VECTOR2I:
							current_value.x = max(current_value.x, value.x)
							current_value.y = max(current_value.y, value.y)
						elif typeof(current_value) == TYPE_VECTOR3 || typeof(current_value) == TYPE_VECTOR3I:
							current_value.x = max(current_value.x, value.x)
							current_value.y = max(current_value.y, value.y)
							current_value.z = max(current_value.z, value.z)
						else:
							current_value = max(current_value, value)
					ShakerTypeBase.BlendingModes.Min:
						if typeof(current_value) == TYPE_VECTOR2 || typeof(current_value) == TYPE_VECTOR2I:
							current_value.x = min(current_value.x, value.x)
							current_value.y = min(current_value.y, value.y)
						elif typeof(current_value) == TYPE_VECTOR3 || typeof(current_value) == TYPE_VECTOR3I:
							current_value.x = min(current_value.x, value.x)
							current_value.y = min(current_value.y, value.y)
							current_value.z = min(current_value.z, value.z)
						else:
							current_value = min(current_value, value)
					ShakerTypeBase.BlendingModes.Average:
						current_value = (current_value + value) * 0.5
					ShakerTypeBase.BlendingModes.Override:
						current_value = value
						
				if current_value != null:
					var _added_value = (current_value - default_value) * _strength
					target.set(property_name,  default_value + _added_value )
					_value_temp[i][property_name]["value"] = _added_value
				else:
					push_error(name," Variable Error: ",target," has no variable named \"",property_name,"\"")
	_last_values = _value_temp
			
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
		is_playing = false
		_fading_out = false
		_last_values.clear()
		shake_finished.emit()

func set_shaker_property(value:Array[ShakerProperty]) -> void:
	shakerProperty = value

func get_shaker_property() -> Array[ShakerProperty]:
	return shakerProperty

# Starts the shake effect
func play_shake() -> void:
	if shakerProperty != null:
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
		if get_parent() is Node:
			Targets.append(get_parent())


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
		if not get_parent() is Node:
			return ["Parent must be Node"]
		
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
		if _last_values.size() > 0:
			for index: int in Targets.size():
				var target:Node = Targets[index]
				var i:int = fmod(index, _last_values.size())
				for shake:ShakerProperty in shakerProperty:
					var current_value = target.get(shake.property_name)
					target.set(shake.property_name, current_value - _last_values[i][shake.property_name]["value"])
		_last_values.clear()
	randomize = value
	randomize_shake()

func _initialize_timer_offset() -> void:
	if !(duration > 0): _timer_offset = 0x80000
	else: _timer_offset = 0.0

func get_randomize() -> bool:
	return randomize
