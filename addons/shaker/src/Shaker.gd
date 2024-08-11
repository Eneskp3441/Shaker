extends Node


func shake_by_preset(preset:ShakerPresetBase, node:Node, duration:float, speed:float=1.0, intensity:float=1.0, fade_in:float=0.25, fade_out:float=2.0):
	if (preset is ShakerPreset2D && not node is Node2D): assert(false, "ShakerPreset2D only works for Node2D type")
	if (preset is ShakerPreset3D && not node is Node3D): assert(false, "ShakerPreset3D only works for Node3D type")
	if preset is ShakerPreset3D:
		var component:ShakerComponent3D = ShakerComponent3D.new() 
		add_child(component)
		component.name = "TEMP_ShakerComponent3D"
		component.custom_target = true
		component.intensity = intensity
		component.Targets.append(node)
		component.duration = duration
		component.shake_speed = speed
		component.fade_in = fade_in
		component.fade_out = fade_out
		component.shakerPreset = preset
		component.shake_finished.connect(_on_shake_finished.bind(component))
		component.play_shake()
	
	elif preset is ShakerPreset2D:
		var component:ShakerComponent2D = ShakerComponent2D.new() 
		component.name = "ShakerComponent2D"
		add_child(component)
		component.custom_target = true
		component.Targets.append(node)
		component.duration = duration
		component.intensity = intensity
		component.shake_speed = speed
		component.fade_in = fade_in
		component.fade_out = fade_out
		component.shakerPreset = preset
		component.shake_finished.connect(_on_shake_finished.bind(component))
		
		component.play_shake()

func shake_property(property:ShakerProperty, node:Node, duration:float, speed:float=1.0, intensity:float=1.0, fade_in:float=0.25, fade_out:float=2.0) -> ShakerComponent:
	var component:ShakerComponent = ShakerComponent.new()
	component.name = "ShakerComponent"
	add_child(component)
	component.custom_target = true
	component.Targets.append(node)
	component.duration = duration
	component.shake_speed = speed
	component.intensity = intensity
	component.fade_in = fade_in
	component.fade_out = fade_out
	component.shakerProperty.append(property)
	component.shake_finished.connect(_on_shake_finished.bind(component))
	
	component.play_shake()
	return component

func shake_emit_3d(position:Vector3,preset:ShakerPreset3D, max_distance:float, duration:float, distance_attenuation:float=0.5, speed:float=1.0, fade_in:float=0.25, fade_out:float=2.0) -> ShakerEmitter3D:
	var component:ShakerEmitter3D = ShakerEmitter3D.new()
	component.name = "ShakerEmitter3D"
	add_child(component)
	component.max_distance = max_distance
	component.global_position = position
	component.duration = duration
	component.shake_speed = speed
	component.fade_in = fade_in
	component.fade_out = fade_out
	component.shakerPreset = preset
	component.collision.shape = SphereShape3D.new()
	component.collision.shape.radius = max_distance
	component.shake_finished.connect(_on_shake_finished.bind(component))
	
	component.play_shake()
	return component

func shake_emit_2d(position:Vector2,preset:ShakerPreset2D, max_distance:float, duration:float, distance_attenuation:float=0.5, speed:float=1.0, fade_in:float=0.25, fade_out:float=2.0) -> ShakerEmitter2D:
	var component:ShakerEmitter2D = ShakerEmitter2D.new()
	component.name = "ShakerEmitter2D"
	add_child(component)
	component.max_distance = max_distance
	component.global_position = position
	component.duration = duration
	component.shake_speed = speed
	component.fade_in = fade_in
	component.fade_out = fade_out
	component.shakerPreset = preset
	component.collision.shape = CircleShape2D.new()
	component.collision.shape.radius = max_distance
	component.shake_finished.connect(_on_shake_finished.bind(component))
	
	component.play_shake()
	return component

func _on_shake_finished(shaker_component) -> void:
	shaker_component.queue_free()
