@icon("res://addons/shaker/assets/ShakerReceiver2D.svg")
@tool
class_name ShakerReceiver2D
extends Node2D

## Transmits values from ShakerEmitter2D to ShakerComponent2D

# Fade-in easing
@export_exp_easing var enter_fade_in: float = 0.1:
	set = set_fade_in,
	get = get_fade_in

# Fade-out easing
@export_exp_easing("attenuation") var exit_fade_out: float = 3.0:
	set = set_fade_out,
	get = get_fade_out

# Private variables
var area2D: Area2D
var position_offset: Vector2 = Vector2.ZERO
var rotation_offset:float = 0.0
var scale_offset: Vector2 = Vector2.ZERO
var emitter_list: Array[EmitterData]

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	_setup_area2D()
	if !Engine.is_editor_hint():
		add_to_group("ShakerReceiver")
		_connect_signals()

# Sets up the Area2D node
func _setup_area2D() -> void:
	for child in get_children():
		if child is Area2D:
			area2D = child
			return

	area2D = Area2D.new()
	var collision = CollisionShape2D.new()
	add_child(area2D)
	area2D.add_child(collision)
	area2D.set_owner(get_tree().edited_scene_root)
	collision.set_owner(get_tree().edited_scene_root)
	area2D.name = "Area2D"
	collision.name = "CollisionShape2D"
	
	area2D.collision_layer = 0
	area2D.collision_mask = 1 << 9

# Connects signals
func _connect_signals() -> void:
	area2D.area_entered.connect(on_area_entered)
	area2D.area_exited.connect(on_area_exited)

# Called every frame
func _process(delta: float) -> void:
	position_offset = Vector2.ZERO
	rotation_offset = 0.0
	scale_offset = Vector2.ZERO
	
	if emitter_list.size() > 0:
		for emitter_data in emitter_list:
			_process_emitter(emitter_data, delta)

# Processes each emitter
func _process_emitter(emitter_data: EmitterData, delta: float) -> void:
	if emitter_data.emitter:
		var ease_in: float = ease(emitter_data.timer, enter_fade_in)
		var ease_out: float = ease(1.0 - (emitter_data.timer - emitter_data.fade_out_timer), exit_fade_out) if emitter_data.fade_out_timer != 0.0 else 1.0
		emitter_data.ease_out_intensity = move_toward(emitter_data.ease_out_intensity, ease_out, delta)
		ease_out = emitter_data.ease_out_intensity
		var max_distance: float = emitter_data.emitter.max_distance
		var distance: float = min(emitter_data.emitter.global_position.distance_to(global_position), max_distance) / max(max_distance, 0.001)
		var attenuation: float = ease(1.0 - distance, emitter_data.emitter.distance_attenuation)
		position_offset += emitter_data.emitter.shake_offset_position * ease_in * ease_out * attenuation
		rotation_offset += emitter_data.emitter.shake_offset_rotation * ease_in * ease_out * attenuation
		scale_offset += emitter_data.emitter.shake_offset_scale * ease_in * ease_out * attenuation
		
		emitter_data.timer += delta
		if ease_out <= delta:
			emitter_list.erase(emitter_data)
	else:
		emitter_list.erase(emitter_data)
# Returns the current shake values
func get_value() -> Array[Vector2]:
	return [position_offset, Vector2(rotation_offset, 0.0), scale_offset]

# Returns configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is ShakerComponent2D:
		return ["Parent must be ShakerComponent2D"]
	var _ex:bool = false
	for i in get_children():
		if i is Area2D:
			_ex = true
			break
	if !_ex:
		return ["ShakerReceiver2D needs Area2D to work"]
	return []

# Called when an area enters
func on_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if node is ShakerEmitter2D:
		var data = EmitterData.new(node)
		emitter_list.append(data)

# Called when an area exits
func on_area_exited(area: Area2D) -> void:
	var node = area.get_parent()
	if node is ShakerEmitter2D:
		for index in emitter_list.size():
			var data = emitter_list[index]
			if data.emitter == node:
				data.fade_out_timer = data.timer
				break

# Setter for enter_fade_in
func set_fade_in(value: float) -> void:
	enter_fade_in = value

# Getter for enter_fade_in
func get_fade_in() -> float:
	return enter_fade_in

# Setter for exit_fade_out
func set_fade_out(value: float) -> void:
	exit_fade_out = value

# Getter for exit_fade_out
func get_fade_out() -> float:
	return exit_fade_out

# EmitterData inner class
class EmitterData:
	var emitter: ShakerEmitter2D
	var timer: float = 0.0
	var fade_out_timer: float = 0.0
	var ease_out_intensity:float = 1.0
	
	func _init(_emitter: ShakerEmitter2D) -> void:
		self.emitter = _emitter
func is_playing() -> bool:
	for i:EmitterData in emitter_list:
		return i.emitter.emitting
	return false

